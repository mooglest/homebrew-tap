class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.61"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.61/afk-macos-arm64.tar.gz"
      sha256 "6ee1715bd813ab52c11d0073b92e39d6fc5e914c4f293cfd3fc89b22c07bae1c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.61/afk-linux-arm64.tar.gz"
      sha256 "294eb90f4a82b9d82d0e67f4d510c9854f3777b68d17ff7a3e106c662b8324b9"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.61/afk-linux-amd64.tar.gz"
      sha256 "465816ceef78e5219039d3dd8fcae066f65801f44818bf2130eb16b41af8b9e0"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.61/afk-linux-amd64.tar.gz"
    sha256 "465816ceef78e5219039d3dd8fcae066f65801f44818bf2130eb16b41af8b9e0"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.61/afk-linux-arm64.tar.gz"
    sha256 "294eb90f4a82b9d82d0e67f4d510c9854f3777b68d17ff7a3e106c662b8324b9"
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
