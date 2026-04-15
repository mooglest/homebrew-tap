class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.85"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.85/afk-macos-arm64.tar.gz"
      sha256 "66a9957ba665845f1a7b9c198cf565a16f7020578f4cc55d1cdc6e6d970178b9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.85/afk-linux-arm64.tar.gz"
      sha256 "66eb980bd80a110a29c38602d4918637212b0b1f0cd81f0ebb10e5203388ea1b"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.85/afk-linux-amd64.tar.gz"
      sha256 "a4e919ba0ee566ce200bcfc3dda3b35bcec40f4898fcb4747eac5888adc52e78"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.85/afk-linux-amd64.tar.gz"
    sha256 "a4e919ba0ee566ce200bcfc3dda3b35bcec40f4898fcb4747eac5888adc52e78"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.85/afk-linux-arm64.tar.gz"
    sha256 "66eb980bd80a110a29c38602d4918637212b0b1f0cd81f0ebb10e5203388ea1b"
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
