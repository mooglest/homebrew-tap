class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.51"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.51/afk-macos-arm64.tar.gz"
      sha256 "2db58e5f861adb81dd4f66e09fb4bae91c46cb83f4310db6856d0756186c99ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.51/afk-linux-arm64.tar.gz"
      sha256 "0cc1a013968fc9134bb18826b912e2d8e67d1660eecf91fde230b605487b72a8"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.51/afk-linux-amd64.tar.gz"
      sha256 "7c89d82628fa6df28c2893f8c461a38884a728a6b461e0274f815e52db90359e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.51/afk-linux-amd64.tar.gz"
    sha256 "7c89d82628fa6df28c2893f8c461a38884a728a6b461e0274f815e52db90359e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.51/afk-linux-arm64.tar.gz"
    sha256 "0cc1a013968fc9134bb18826b912e2d8e67d1660eecf91fde230b605487b72a8"
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
