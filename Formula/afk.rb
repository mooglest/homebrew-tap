class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.0/afk-macos-arm64.tar.gz"
      sha256 "b78644fbba855a7aa70e0e43e80eacb4fa0c381ff34e15478efbd399f3931804"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.0/afk-linux-arm64.tar.gz"
      sha256 "cc17467f24506a3794984eaf3cfbcbfa8080776d31e16cc36f5821f8cc8d93f7"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.0/afk-linux-amd64.tar.gz"
      sha256 "2fc9d304b53b07fe5d58fb416e146bef177d3013a69ab896ef559447c6a49a61"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.0/afk-linux-amd64.tar.gz"
    sha256 "2fc9d304b53b07fe5d58fb416e146bef177d3013a69ab896ef559447c6a49a61"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.0/afk-linux-arm64.tar.gz"
    sha256 "cc17467f24506a3794984eaf3cfbcbfa8080776d31e16cc36f5821f8cc8d93f7"
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
