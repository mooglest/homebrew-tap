class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.30"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.30/afk-macos-arm64.tar.gz"
      sha256 "3435f9ff8e3f297c51d5a2cf2c4f9190b229b6e3290b0e59f335294dfbbbf2f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.30/afk-linux-arm64.tar.gz"
      sha256 "26e5aa7066e75ae04a0066ec238e2ccf91219536c394909fc3a2f48ed129e6fa"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.30/afk-linux-amd64.tar.gz"
      sha256 "a60667d10e003b6c50e175686e6b0f07ef0745acf0dab0ce508977078a700385"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.30/afk-linux-amd64.tar.gz"
    sha256 "a60667d10e003b6c50e175686e6b0f07ef0745acf0dab0ce508977078a700385"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.30/afk-linux-arm64.tar.gz"
    sha256 "26e5aa7066e75ae04a0066ec238e2ccf91219536c394909fc3a2f48ed129e6fa"
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
