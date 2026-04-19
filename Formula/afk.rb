class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.9-SNAPSHOT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.9-SNAPSHOT/afk-macos-arm64.tar.gz"
      sha256 "cdb56e86fd7a09a7851b089a3de3237a68cdb29e66310be1efef4311253f70db"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.9-SNAPSHOT/afk-linux-arm64.tar.gz"
      sha256 "aa8f65aba2c3f8e905376592759293c36abb6551f7e39441244e24286d1ad9a6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.9-SNAPSHOT/afk-linux-amd64.tar.gz"
      sha256 "6731ff114f048f03116638cc570ebe81ffafd21d5c3d13a71f1f3e85d8fc7a66"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.9-SNAPSHOT/afk-linux-amd64.tar.gz"
    sha256 "6731ff114f048f03116638cc570ebe81ffafd21d5c3d13a71f1f3e85d8fc7a66"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.9-SNAPSHOT/afk-linux-arm64.tar.gz"
    sha256 "aa8f65aba2c3f8e905376592759293c36abb6551f7e39441244e24286d1ad9a6"
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
