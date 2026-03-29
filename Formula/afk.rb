class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.15"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.15/afk-macos-arm64.tar.gz"
      sha256 "57d4275d926056559badbd1abdaabeac1b8500cd99e6e71db28ea2d886fa3233"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.15/afk-linux-arm64.tar.gz"
      sha256 "7db701a77f25151cadbaff619af8651491c87bb9513d4d5aad5e7c68bb33e697"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.15/afk-linux-amd64.tar.gz"
      sha256 "a0499f3323a8fc89d7dea3e23c444bea35b2ccf0a23f4d826c6de776610a6f17"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.15/afk-linux-amd64.tar.gz"
    sha256 "a0499f3323a8fc89d7dea3e23c444bea35b2ccf0a23f4d826c6de776610a6f17"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.15/afk-linux-arm64.tar.gz"
    sha256 "7db701a77f25151cadbaff619af8651491c87bb9513d4d5aad5e7c68bb33e697"
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
