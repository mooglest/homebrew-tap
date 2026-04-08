class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.55"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.55/afk-macos-arm64.tar.gz"
      sha256 "b3dfd582f98ff909f49e38a42dedeff4de2981fec0e0b6a73e52ef1f6ff2c8c0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.55/afk-linux-arm64.tar.gz"
      sha256 "9c580cf42c8dc4714bc5b919b1eb9a6936fd2cd0f6e339248cbb3ab4d4b865e6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.55/afk-linux-amd64.tar.gz"
      sha256 "12619a3b2cc0fbd1149a642e77b90383d43e33db25589673ce798cf9f0f0201c"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.55/afk-linux-amd64.tar.gz"
    sha256 "12619a3b2cc0fbd1149a642e77b90383d43e33db25589673ce798cf9f0f0201c"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.55/afk-linux-arm64.tar.gz"
    sha256 "9c580cf42c8dc4714bc5b919b1eb9a6936fd2cd0f6e339248cbb3ab4d4b865e6"
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
