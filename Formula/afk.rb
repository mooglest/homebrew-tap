class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.94"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.94/afk-macos-arm64.tar.gz"
      sha256 "b44ec61dcd9ebc62360335c7f5f5b9dca56999831c9e25616c7ef101bad552d9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.94/afk-linux-arm64.tar.gz"
      sha256 "041b57e84b3fc1448d528c415fade6ce9583e0a084ddc96cc59384390d7df509"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.94/afk-linux-amd64.tar.gz"
      sha256 "c1cb59095ac5b1e340ced952568ed5ffba57ac2134746c8bfe7194d741458eea"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.94/afk-linux-amd64.tar.gz"
    sha256 "c1cb59095ac5b1e340ced952568ed5ffba57ac2134746c8bfe7194d741458eea"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.94/afk-linux-arm64.tar.gz"
    sha256 "041b57e84b3fc1448d528c415fade6ce9583e0a084ddc96cc59384390d7df509"
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
