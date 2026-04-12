class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.68"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.68/afk-macos-arm64.tar.gz"
      sha256 "ea8526aa9ea4dfaa4ae9e6659680b32b1d15b8391bb4e655ec13e2e4e48f6fee"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.68/afk-linux-arm64.tar.gz"
      sha256 "28ebf0d964924d5559b2d403fdc72858d0954c83dfc3d29848f9dff0856b0256"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.68/afk-linux-amd64.tar.gz"
      sha256 "288593d788d551ea2dc280aa9f234921c422cc709808dc979c7635d338ff44ac"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.68/afk-linux-amd64.tar.gz"
    sha256 "288593d788d551ea2dc280aa9f234921c422cc709808dc979c7635d338ff44ac"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.68/afk-linux-arm64.tar.gz"
    sha256 "28ebf0d964924d5559b2d403fdc72858d0954c83dfc3d29848f9dff0856b0256"
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
