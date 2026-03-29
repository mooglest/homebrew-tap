class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.7"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.7/afk-macos-arm64.tar.gz"
      sha256 "011306b9ee32ed632de1d065ed59257309bce4cb5116d4c581dc53192f08adb6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.7/afk-linux-arm64.tar.gz"
      sha256 "60b892401285a4fd51f1c4e54a31f713307446351b4da4bf04cdbf225678874b"
    else
      url "https://github.com/mooglest/afk/releases/download/0.0.7/afk-linux-amd64.tar.gz"
      sha256 "6949ac116777efcc5c2536b158466050dc594138534ff5efd4ddbfe97de39822"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.7/afk-linux-amd64.tar.gz"
    sha256 "6949ac116777efcc5c2536b158466050dc594138534ff5efd4ddbfe97de39822"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.7/afk-linux-arm64.tar.gz"
    sha256 "60b892401285a4fd51f1c4e54a31f713307446351b4da4bf04cdbf225678874b"
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
