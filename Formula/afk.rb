class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.52"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-macos-arm64.tar.gz"
      sha256 "39895d2310c48e985c20e6d4a83cc8ba257c683c81cd3fccb67d05d32a559283"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-arm64.tar.gz"
      sha256 "298265d2a6acac4df1296ff1cc03ea990bae3f4a99fe84b4a8355b3768ed0c0d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-amd64.tar.gz"
      sha256 "bf9598defe10a5419eb277647457653c3f482a708b47b22a43ff94024e24fcc5"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-amd64.tar.gz"
    sha256 "bf9598defe10a5419eb277647457653c3f482a708b47b22a43ff94024e24fcc5"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-arm64.tar.gz"
    sha256 "298265d2a6acac4df1296ff1cc03ea990bae3f4a99fe84b4a8355b3768ed0c0d"
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
