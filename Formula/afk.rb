class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.23"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23/afk-macos-arm64.tar.gz"
      sha256 "1a4783d9b8878b10e0c1203cecebe11ca5b44e3d07ce31e5cf75bdba3c096f15"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23/afk-linux-arm64.tar.gz"
      sha256 "1bff82598203ae20bfd05378b22aef7a4337705921675448c64383c140f94a5d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23/afk-linux-amd64.tar.gz"
      sha256 "2604fdabffeda315ad285cd74f037bfdde3a268e5bfc5b329ebe2d58b18d1b67"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23/afk-linux-amd64.tar.gz"
    sha256 "2604fdabffeda315ad285cd74f037bfdde3a268e5bfc5b329ebe2d58b18d1b67"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23/afk-linux-arm64.tar.gz"
    sha256 "1bff82598203ae20bfd05378b22aef7a4337705921675448c64383c140f94a5d"
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
