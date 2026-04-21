class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.27"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.27/afk-macos-arm64.tar.gz"
      sha256 "478bd131df80d2a78ea7035b127141455952c6f6bae84e2eb692ea3ff76b6d26"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.27/afk-linux-arm64.tar.gz"
      sha256 "2f95ea21686ebd02e271e54c58a76eff7c0e5e7a14ae9508bd2825fd3b2e1d48"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.27/afk-linux-amd64.tar.gz"
      sha256 "3d7e80e79d895f5b51b3d004cb558dbe3ba27756e8c4ab88797ab3da089469b5"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.27/afk-linux-amd64.tar.gz"
    sha256 "3d7e80e79d895f5b51b3d004cb558dbe3ba27756e8c4ab88797ab3da089469b5"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.27/afk-linux-arm64.tar.gz"
    sha256 "2f95ea21686ebd02e271e54c58a76eff7c0e5e7a14ae9508bd2825fd3b2e1d48"
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
