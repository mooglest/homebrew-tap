class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.24"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.24/afk-macos-arm64.tar.gz"
      sha256 "b99fc996da882dbd7fa650ff131f110c7954b41c2a8fe7c571be778bde81943a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.24/afk-linux-arm64.tar.gz"
      sha256 "93a34437e587428cff93a33efb3249506ea16ec73b6329b1f386337295ebacef"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.24/afk-linux-amd64.tar.gz"
      sha256 "1b4f06869f5088bc0529d1268be3599eeeb5819725c2f45beb3cb36e26708837"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.24/afk-linux-amd64.tar.gz"
    sha256 "1b4f06869f5088bc0529d1268be3599eeeb5819725c2f45beb3cb36e26708837"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.24/afk-linux-arm64.tar.gz"
    sha256 "93a34437e587428cff93a33efb3249506ea16ec73b6329b1f386337295ebacef"
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
