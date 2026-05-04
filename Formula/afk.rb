class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.18"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.18/afk-macos-arm64.tar.gz"
      sha256 "9fcc82e5a5ba9a608afabb84c0d0bb0eb4f32a8419b6e93773b3e10a87331115"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.18/afk-linux-arm64.tar.gz"
      sha256 "d31f7bf3bf1c4b8ead5130b7722abdfc69d3aa310edba7ad280ada82f9ad9064"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.18/afk-linux-amd64.tar.gz"
      sha256 "b8208b023c6a2518848797a8aa7fb432dc44c2caa24a91c44fde688ac9bf9fc2"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.18/afk-linux-amd64.tar.gz"
    sha256 "b8208b023c6a2518848797a8aa7fb432dc44c2caa24a91c44fde688ac9bf9fc2"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.18/afk-linux-arm64.tar.gz"
    sha256 "d31f7bf3bf1c4b8ead5130b7722abdfc69d3aa310edba7ad280ada82f9ad9064"
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
