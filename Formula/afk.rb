class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.18"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.18/afk-macos-arm64.tar.gz"
      sha256 "3a31ce3b18c91ba914a415f15c195262422fcf5eff611b557e83a7864e094f10"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.18/afk-linux-arm64.tar.gz"
      sha256 "57978276f24308bc131a5a65da4d48de7a97f78171f8f59842a46c1135f9d118"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.18/afk-linux-amd64.tar.gz"
      sha256 "84dca4848341a3ebce61cf07a96aef4cd9e19dfe8063aa309296f2570ff01bfb"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.18/afk-linux-amd64.tar.gz"
    sha256 "84dca4848341a3ebce61cf07a96aef4cd9e19dfe8063aa309296f2570ff01bfb"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.18/afk-linux-arm64.tar.gz"
    sha256 "57978276f24308bc131a5a65da4d48de7a97f78171f8f59842a46c1135f9d118"
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
