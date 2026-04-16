class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.89"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.89/afk-macos-arm64.tar.gz"
      sha256 "9f78e0eae661fe9654ba20f46bbad62b260225a9c6b682150ad9d2e173c4bd7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.89/afk-linux-arm64.tar.gz"
      sha256 "e078f0d04e0154eadd93cbd4f5d14c25e7d5fef119aed336beb423651a32029f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.89/afk-linux-amd64.tar.gz"
      sha256 "a35069eca436475d2e804c3a65e6be474d4f1f03ab66a3f14a0b8f1764dc23b3"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.89/afk-linux-amd64.tar.gz"
    sha256 "a35069eca436475d2e804c3a65e6be474d4f1f03ab66a3f14a0b8f1764dc23b3"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.89/afk-linux-arm64.tar.gz"
    sha256 "e078f0d04e0154eadd93cbd4f5d14c25e7d5fef119aed336beb423651a32029f"
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
