class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.44"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.44/afk-macos-arm64.tar.gz"
      sha256 "d9bf6ba1679925ef960b4a65750b3153909bbe55740d4af6cf85181eb5408b34"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.44/afk-linux-arm64.tar.gz"
      sha256 "854c715b266912794a032e7d9738f832aac13ba5aac09ea5d6ff2886aa5cdd88"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.44/afk-linux-amd64.tar.gz"
      sha256 "f1046ae7ed65b43d091770b0e8afa5403aeab6c35cbdb94bf22edea8a367b4c6"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.44/afk-linux-amd64.tar.gz"
    sha256 "f1046ae7ed65b43d091770b0e8afa5403aeab6c35cbdb94bf22edea8a367b4c6"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.44/afk-linux-arm64.tar.gz"
    sha256 "854c715b266912794a032e7d9738f832aac13ba5aac09ea5d6ff2886aa5cdd88"
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
