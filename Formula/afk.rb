class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.15"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.15/afk-macos-arm64.tar.gz"
      sha256 "d3002b9017513225e66d2cc74d2c8e6fc0fe94467f804ec9f42be5ad59f3960b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.15/afk-linux-arm64.tar.gz"
      sha256 "2baf80ae98673894ac3d487e6d5478498b9e689d42ee3889399a6f3715391d97"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.15/afk-linux-amd64.tar.gz"
      sha256 "2d07333b694df2b35398ab35a7d45526b127627933f251495208b883ae56d8d4"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.15/afk-linux-amd64.tar.gz"
    sha256 "2d07333b694df2b35398ab35a7d45526b127627933f251495208b883ae56d8d4"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.15/afk-linux-arm64.tar.gz"
    sha256 "2baf80ae98673894ac3d487e6d5478498b9e689d42ee3889399a6f3715391d97"
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
