class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.74"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.74/afk-macos-arm64.tar.gz"
      sha256 "c22b37b998244cc32939ceae62ed285d990d976014b59df2c08b733496903a2d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.74/afk-linux-arm64.tar.gz"
      sha256 "a0cb77834337ea3be3bc8501306a6f4ef46fac4f927037da22664d173c1c8086"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.74/afk-linux-amd64.tar.gz"
      sha256 "ddb9359358b1d95a64985e5f111b17acab6c8b0681c186df8133ae7056a8dc06"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.74/afk-linux-amd64.tar.gz"
    sha256 "ddb9359358b1d95a64985e5f111b17acab6c8b0681c186df8133ae7056a8dc06"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.74/afk-linux-arm64.tar.gz"
    sha256 "a0cb77834337ea3be3bc8501306a6f4ef46fac4f927037da22664d173c1c8086"
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
