class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.5"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.5/afk-macos-arm64.tar.gz"
      sha256 "d8d708f4637480bcd1d4af15071da3e79e14e02d169959a9935bae9b31b651cd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.5/afk-linux-arm64.tar.gz"
      sha256 "4975c9c3a8ac81732eb7944356fda7ccac5188a6d3d9dc776514057a95576a73"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.5/afk-linux-amd64.tar.gz"
      sha256 "f52964e9ccd1fe8179b1d025183fa3a252c283bd9c0925f7d9cd9141acc1d0ba"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.5/afk-linux-amd64.tar.gz"
    sha256 "f52964e9ccd1fe8179b1d025183fa3a252c283bd9c0925f7d9cd9141acc1d0ba"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.5/afk-linux-arm64.tar.gz"
    sha256 "4975c9c3a8ac81732eb7944356fda7ccac5188a6d3d9dc776514057a95576a73"
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
