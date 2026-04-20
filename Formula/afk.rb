class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.16"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.16/afk-macos-arm64.tar.gz"
      sha256 "1455038292bd8a4e5b73acc978a6b2e98dba5c52ecdd71e16529b96048b23f89"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.16/afk-linux-arm64.tar.gz"
      sha256 "d56d3f2808bfbdc6c49dec6911d96176e7c6e0f64df928877982c85a67f62065"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.16/afk-linux-amd64.tar.gz"
      sha256 "4a0d667a44109495c3d6b4c5c90bae9e103fc010a732c54d45645dae98a61655"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.16/afk-linux-amd64.tar.gz"
    sha256 "4a0d667a44109495c3d6b4c5c90bae9e103fc010a732c54d45645dae98a61655"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.16/afk-linux-arm64.tar.gz"
    sha256 "d56d3f2808bfbdc6c49dec6911d96176e7c6e0f64df928877982c85a67f62065"
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
