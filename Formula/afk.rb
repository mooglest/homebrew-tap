class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.86"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.86/afk-macos-arm64.tar.gz"
      sha256 "085c60db41973bb8e7a51b24c1f1de333c506d2f3e4c6f6ab5b6f86c72ae975d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.86/afk-linux-arm64.tar.gz"
      sha256 "29d870d93312f5395c9eba2b16d199efac3ae28471473283cf53f79a35f0d012"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.86/afk-linux-amd64.tar.gz"
      sha256 "fa39c6a511bfecb8cb9d7a43a67ced1d44c61d466b16775504d969fd0cb39c47"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.86/afk-linux-amd64.tar.gz"
    sha256 "fa39c6a511bfecb8cb9d7a43a67ced1d44c61d466b16775504d969fd0cb39c47"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.86/afk-linux-arm64.tar.gz"
    sha256 "29d870d93312f5395c9eba2b16d199efac3ae28471473283cf53f79a35f0d012"
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
