class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.42"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.42/afk-macos-arm64.tar.gz"
      sha256 "fd563f5244ab18e43da06a9d111d04fb560fe19f58746c98066a264d759a18ad"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.42/afk-linux-arm64.tar.gz"
      sha256 "830c023f89f556dd0c9dcbc1afa6f35e2d646f86179995dc761135b95542c4d0"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.42/afk-linux-amd64.tar.gz"
      sha256 "e36447a56f7656bdbcc2dc8aacb0c87a2c04a0070a75d0b15edf3aee290f3614"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.42/afk-linux-amd64.tar.gz"
    sha256 "e36447a56f7656bdbcc2dc8aacb0c87a2c04a0070a75d0b15edf3aee290f3614"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.42/afk-linux-arm64.tar.gz"
    sha256 "830c023f89f556dd0c9dcbc1afa6f35e2d646f86179995dc761135b95542c4d0"
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
