class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.84"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.84/afk-macos-arm64.tar.gz"
      sha256 "892fda8285cb0aaf69353aa668f47569c0f30514be53fc674bed038498142b8e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.84/afk-linux-arm64.tar.gz"
      sha256 "177ba6eed249715c1206ddbc578c9b6cb43ff80106eda39036812178e1fdc9d6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.84/afk-linux-amd64.tar.gz"
      sha256 "45cddc1d04b0d7d064eab06227722dd4c423bc8f5a9da9c1adf83bdf70bd5c2f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.84/afk-linux-amd64.tar.gz"
    sha256 "45cddc1d04b0d7d064eab06227722dd4c423bc8f5a9da9c1adf83bdf70bd5c2f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.84/afk-linux-arm64.tar.gz"
    sha256 "177ba6eed249715c1206ddbc578c9b6cb43ff80106eda39036812178e1fdc9d6"
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
