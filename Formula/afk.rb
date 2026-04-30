class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.6/afk-macos-arm64.tar.gz"
      sha256 "8975fd58fb8a4399bee5f88244541dd42196ed9c2e487db2b4e03273aa371028"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.6/afk-linux-arm64.tar.gz"
      sha256 "8bee3b3589e6a7f30e8481047720e317ffcd43374831783ba9049e2ad203556c"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.6/afk-linux-amd64.tar.gz"
      sha256 "3d4fd7386f36bd5cee2a44740f850bf760c180a697ddb3eba8f8b74c1a59aac5"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.6/afk-linux-amd64.tar.gz"
    sha256 "3d4fd7386f36bd5cee2a44740f850bf760c180a697ddb3eba8f8b74c1a59aac5"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.6/afk-linux-arm64.tar.gz"
    sha256 "8bee3b3589e6a7f30e8481047720e317ffcd43374831783ba9049e2ad203556c"
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
