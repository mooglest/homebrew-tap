class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.95"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.95/afk-macos-arm64.tar.gz"
      sha256 "2247c2ea2789dce3a3201f7e0e1f6c8feb5ef2b3cf89be9e8f80930292281046"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.95/afk-linux-arm64.tar.gz"
      sha256 "c1cad05640798280d5792fd14fca51c9554b178ce8f18df25f006b6149318739"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.95/afk-linux-amd64.tar.gz"
      sha256 "18b56e4ce1358c35596c0bf0fcaec0017122161aa6a519f7e2e74846a3451e57"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.95/afk-linux-amd64.tar.gz"
    sha256 "18b56e4ce1358c35596c0bf0fcaec0017122161aa6a519f7e2e74846a3451e57"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.95/afk-linux-arm64.tar.gz"
    sha256 "c1cad05640798280d5792fd14fca51c9554b178ce8f18df25f006b6149318739"
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
