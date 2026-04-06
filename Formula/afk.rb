class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.41"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.41/afk-macos-arm64.tar.gz"
      sha256 "607464448d00c914de416468f9628c7dabb2600b0c458d145654f4cc947d967e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.41/afk-linux-arm64.tar.gz"
      sha256 "b963fef275e398b1e879608a81f2f04036956cb66271a9c43599a172cbdb3d2d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.41/afk-linux-amd64.tar.gz"
      sha256 "5faf671669fd277d2aadbaf1c1cd05d9d70dedff86a9bd63f0c9621c567e3b18"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.41/afk-linux-amd64.tar.gz"
    sha256 "5faf671669fd277d2aadbaf1c1cd05d9d70dedff86a9bd63f0c9621c567e3b18"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.41/afk-linux-arm64.tar.gz"
    sha256 "b963fef275e398b1e879608a81f2f04036956cb66271a9c43599a172cbdb3d2d"
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
