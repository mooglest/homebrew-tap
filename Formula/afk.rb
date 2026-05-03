class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.14"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.14/afk-macos-arm64.tar.gz"
      sha256 "ed236cd0dcc6c7d78effca4b4ad0300ad29d97e201e05ee373c7405007d7dc8c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.14/afk-linux-arm64.tar.gz"
      sha256 "c04ced16dd1afd7c18b4793b80dffbb85859a5f4b0322d19fa68b0fdfbcb5d4f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.14/afk-linux-amd64.tar.gz"
      sha256 "a66efff9fb3e278d28b980caf562362c7b2a840d963966fc2776c28c1dd8c620"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.14/afk-linux-amd64.tar.gz"
    sha256 "a66efff9fb3e278d28b980caf562362c7b2a840d963966fc2776c28c1dd8c620"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.14/afk-linux-arm64.tar.gz"
    sha256 "c04ced16dd1afd7c18b4793b80dffbb85859a5f4b0322d19fa68b0fdfbcb5d4f"
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
