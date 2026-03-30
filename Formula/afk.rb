class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.25"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-macos-arm64.tar.gz"
      sha256 "f289f0fb37040b0166e2ef1b8bd281b21579b22072f683245e242a9d3c0ffdcf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
      sha256 "6c6a4019258073e927602680831d813c07b4d728bbcbbedde61ff22ef9190546"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
      sha256 "c62e4a5a2e00ad202c0eef13e1f7e32f29751dac4b1bd07fce2f1d8d94448c94"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
    sha256 "c62e4a5a2e00ad202c0eef13e1f7e32f29751dac4b1bd07fce2f1d8d94448c94"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
    sha256 "6c6a4019258073e927602680831d813c07b4d728bbcbbedde61ff22ef9190546"
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
