class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.25"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-macos-arm64.tar.gz"
      sha256 "6b04c26518794a20a6e7e1c2dd16d68a5258c1f8fec4cd9e5560d40aa3f2fece"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
      sha256 "67ff8a2d3d575b21676f3d9fd5cdc4b1bce896301290838fdd852c6e8c55099b"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
      sha256 "010ad76a94dd94c48ab1ffb0f9d5401262f139585014ddcb8e747b759c7211b2"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
    sha256 "010ad76a94dd94c48ab1ffb0f9d5401262f139585014ddcb8e747b759c7211b2"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
    sha256 "67ff8a2d3d575b21676f3d9fd5cdc4b1bce896301290838fdd852c6e8c55099b"
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
