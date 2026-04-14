class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.78"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.78/afk-macos-arm64.tar.gz"
      sha256 "453b7987b686553c00e3c3e2c316c74bf4fd04409a12c67bdd0c228c73b0ac57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.78/afk-linux-arm64.tar.gz"
      sha256 "ae6831a9fd4087acc1c5cd155e56c4381520be335129f47b136b8e09ac82518c"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.78/afk-linux-amd64.tar.gz"
      sha256 "944a45a8a6cdb7cbbe918488efa5875f1b1bcea2361659dce4e03f23b76c2f1b"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.78/afk-linux-amd64.tar.gz"
    sha256 "944a45a8a6cdb7cbbe918488efa5875f1b1bcea2361659dce4e03f23b76c2f1b"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.78/afk-linux-arm64.tar.gz"
    sha256 "ae6831a9fd4087acc1c5cd155e56c4381520be335129f47b136b8e09ac82518c"
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
