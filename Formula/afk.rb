class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.76"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.76/afk-macos-arm64.tar.gz"
      sha256 "271e179224ef494b0c3227d5b05af96e89b10b7a9c2c2cb870327d21e28cee18"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.76/afk-linux-arm64.tar.gz"
      sha256 "e61755a133fdd1fa598cce82ec81a39b162aee9fe562f58f620d7910f066c9be"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.76/afk-linux-amd64.tar.gz"
      sha256 "5c02bece325533f2f15cd6433b95c3fb452fe3d673cdd530f984db8ecb60b3b7"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.76/afk-linux-amd64.tar.gz"
    sha256 "5c02bece325533f2f15cd6433b95c3fb452fe3d673cdd530f984db8ecb60b3b7"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.76/afk-linux-arm64.tar.gz"
    sha256 "e61755a133fdd1fa598cce82ec81a39b162aee9fe562f58f620d7910f066c9be"
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
