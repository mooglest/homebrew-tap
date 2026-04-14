class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.77"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.77/afk-macos-arm64.tar.gz"
      sha256 "2491522982d4a7c4553013531e856fc550715d3cdf18544d8f8ed40d76127f25"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.77/afk-linux-arm64.tar.gz"
      sha256 "0a14848cb1be6f097ec0ae32822e2f124001a38fe4edca726d6b422ce4b99f57"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.77/afk-linux-amd64.tar.gz"
      sha256 "8026285ace913efbaca3aff288a82cba075442bbe8bf523d4c5f166fa6259b32"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.77/afk-linux-amd64.tar.gz"
    sha256 "8026285ace913efbaca3aff288a82cba075442bbe8bf523d4c5f166fa6259b32"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.77/afk-linux-arm64.tar.gz"
    sha256 "0a14848cb1be6f097ec0ae32822e2f124001a38fe4edca726d6b422ce4b99f57"
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
