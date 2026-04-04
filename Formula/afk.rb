class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.38"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.38/afk-macos-arm64.tar.gz"
      sha256 "55b716f8384a012cf7b1765ccc5f29e8fddb4f75c20456003ced29ec6ff90457"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.38/afk-linux-arm64.tar.gz"
      sha256 "13623bed586c5bd58ff3581ace503891bd70f3ae32e97b78b5916599018db225"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.38/afk-linux-amd64.tar.gz"
      sha256 "3201d8143c66ba46fbc77123084c35ca933b26a491c9f0862f0c02a59bb094e0"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.38/afk-linux-amd64.tar.gz"
    sha256 "3201d8143c66ba46fbc77123084c35ca933b26a491c9f0862f0c02a59bb094e0"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.38/afk-linux-arm64.tar.gz"
    sha256 "13623bed586c5bd58ff3581ace503891bd70f3ae32e97b78b5916599018db225"
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
