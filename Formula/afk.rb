class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.48"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.48/afk-macos-arm64.tar.gz"
      sha256 "e45b0f928384fa1c3c0df7c4fa340d0d31f515938bc64e92bb90738c7588e131"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.48/afk-linux-arm64.tar.gz"
      sha256 "c62e9c765f1be91a93c7df054d63a55b859cc8ecec78e79519780a9f8ef40cf8"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.48/afk-linux-amd64.tar.gz"
      sha256 "aaf3998ef894dfb37f3a917e26763793f04f5f65c25f95516c90b2d9d2a53142"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.48/afk-linux-amd64.tar.gz"
    sha256 "aaf3998ef894dfb37f3a917e26763793f04f5f65c25f95516c90b2d9d2a53142"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.48/afk-linux-arm64.tar.gz"
    sha256 "c62e9c765f1be91a93c7df054d63a55b859cc8ecec78e79519780a9f8ef40cf8"
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
