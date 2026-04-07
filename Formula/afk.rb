class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.49"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-macos-arm64.tar.gz"
      sha256 "5a7a9f5a657871117d2a7400d542b44f9be8d67da4de7f65d77573f343ca5404"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-arm64.tar.gz"
      sha256 "c383b10ab0f795db6e12b4b2ca5386ba1ed2281ccc6e27e65ec069b8cbd713cd"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-amd64.tar.gz"
      sha256 "e7f8391234ba5447f3b00bda3e81726ae531d9b95e3118f7405fd3d3532d6043"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-amd64.tar.gz"
    sha256 "e7f8391234ba5447f3b00bda3e81726ae531d9b95e3118f7405fd3d3532d6043"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-arm64.tar.gz"
    sha256 "c383b10ab0f795db6e12b4b2ca5386ba1ed2281ccc6e27e65ec069b8cbd713cd"
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
