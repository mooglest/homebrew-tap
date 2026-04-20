class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.17"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.17/afk-macos-arm64.tar.gz"
      sha256 "27738baeab6cb15e1e2fddc651235f4b3e01ac49ba29d83f779a1f6b230d82a0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.17/afk-linux-arm64.tar.gz"
      sha256 "d0527c6000f2ceaa55d01ea63c3c885524126f6c4afe4f0098fd92efa466c780"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.17/afk-linux-amd64.tar.gz"
      sha256 "6b4ba99800f819f5dd90e8a550f87ca782e51b1ddf3657e4139f075bb2f0eb70"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.17/afk-linux-amd64.tar.gz"
    sha256 "6b4ba99800f819f5dd90e8a550f87ca782e51b1ddf3657e4139f075bb2f0eb70"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.17/afk-linux-arm64.tar.gz"
    sha256 "d0527c6000f2ceaa55d01ea63c3c885524126f6c4afe4f0098fd92efa466c780"
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
