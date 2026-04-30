class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.7"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.7/afk-macos-arm64.tar.gz"
      sha256 "da7cea606e738aa132889e6e994d33793f00776330fe923217f5dff987b98655"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.7/afk-linux-arm64.tar.gz"
      sha256 "21f849b7563b5399c1e07b8dd459c2fde698cfaa6aa035645a2bcbfcf343ce06"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.7/afk-linux-amd64.tar.gz"
      sha256 "1c808bee9f5118d56291a1f5bb4916bbd7ec70d3062225366a34c59c4b878b11"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.7/afk-linux-amd64.tar.gz"
    sha256 "1c808bee9f5118d56291a1f5bb4916bbd7ec70d3062225366a34c59c4b878b11"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.7/afk-linux-arm64.tar.gz"
    sha256 "21f849b7563b5399c1e07b8dd459c2fde698cfaa6aa035645a2bcbfcf343ce06"
  end

  def install
    if OS.mac?
      libexec.install "afk" => "afk-macos"
      resource("afk-linux-amd64").stage do
        libexec.install "afk" => "afk-linux-amd64"
      end
      resource("afk-linux-arm64").stage do
        libexec.install "afk" => "afk-linux-arm64"
      end
      (bin/"afk").write_env_script libexec/"afk-macos",
        AFK_DOCKER_BINARY_AMD64: opt_libexec/"afk-linux-amd64",
        AFK_DOCKER_BINARY_ARM64: opt_libexec/"afk-linux-arm64",
        AFK_DOCKER_BINARY: opt_libexec/"afk-linux-amd64"
    else
      bin.install "afk"
    end
  end

  def caveats
    <<~EOS
      AFK stores user data in ~/.afk
      The directory will be created automatically on first run.

      Please login to https://afk.mooglest.com and update the api_key in ~/.afk/config
    EOS
  end

  service do
    run [opt_bin/"afk", "daemon"]
    keep_alive true
    log_path var/"log/afk.log"
    error_log_path var/"log/afk.log"
    working_dir ENV["HOME"]
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/afk --help")
  end
end
