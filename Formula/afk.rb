class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.4/afk-macos-arm64.tar.gz"
      sha256 "c8b7d115ffcf20200bf248e958b20bc82fc234b52a50de06ab10c6c33e0f109d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.4/afk-linux-arm64.tar.gz"
      sha256 "bb2a60beb034dafe79801f8932c523f3c67a7043e7dd51fa98855f8bac54f93b"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.4/afk-linux-amd64.tar.gz"
      sha256 "d86a2196bb6d7d0281783062f59d7468e191768cf54aebbf58d928a7b085929d"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.4/afk-linux-amd64.tar.gz"
    sha256 "d86a2196bb6d7d0281783062f59d7468e191768cf54aebbf58d928a7b085929d"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.4/afk-linux-arm64.tar.gz"
    sha256 "bb2a60beb034dafe79801f8932c523f3c67a7043e7dd51fa98855f8bac54f93b"
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
