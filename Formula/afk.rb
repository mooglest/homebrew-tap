class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.10"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.10/afk-macos-arm64.tar.gz"
      sha256 "5b4eb1892b1249211ab3fae6bbdecd364c932f5d4bf366612bb0c047487380be"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.10/afk-linux-arm64.tar.gz"
      sha256 "bdf6f4bda64793f09d2a01cca639f5eb48e5b51712afbe68654dcad6e30c0d42"
    else
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.10/afk-linux-amd64.tar.gz"
      sha256 "6b487f3663ea04abdaf1bdb96c9d629c142bb96b1f7a3e1ff2aef8dc366eb63e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.10/afk-linux-amd64.tar.gz"
    sha256 "6b487f3663ea04abdaf1bdb96c9d629c142bb96b1f7a3e1ff2aef8dc366eb63e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.10/afk-linux-arm64.tar.gz"
    sha256 "bdf6f4bda64793f09d2a01cca639f5eb48e5b51712afbe68654dcad6e30c0d42"
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
