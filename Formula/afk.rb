class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.11"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.11/afk-macos-arm64.tar.gz"
      sha256 "bbfcb01b8a1dcc40ac4d15bedd33177764ce30a826c46f5f58edf8a27c391f07"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.11/afk-linux-arm64.tar.gz"
      sha256 "4e76b6594f234cb9f49f96aa61a71eda3961af29f52534a7afcfcdd0cb039d04"
    else
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.11/afk-linux-amd64.tar.gz"
      sha256 "2451ae8d4e3e96adaf91b9ed8af4ad15583d10f867be6abce25ebb3d2541e8f3"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.11/afk-linux-amd64.tar.gz"
    sha256 "2451ae8d4e3e96adaf91b9ed8af4ad15583d10f867be6abce25ebb3d2541e8f3"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.11/afk-linux-arm64.tar.gz"
    sha256 "4e76b6594f234cb9f49f96aa61a71eda3961af29f52534a7afcfcdd0cb039d04"
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
