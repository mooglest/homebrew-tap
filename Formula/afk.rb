class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.32"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.32/afk-macos-arm64.tar.gz"
      sha256 "2197aca2d7caaa67ef8d910caa264d1dbb2d741bbec681060003a8877dbd47ba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.32/afk-linux-arm64.tar.gz"
      sha256 "d645f91cafdee70be332f6e7e5a50e6902d0b3409ed41c5cceb4c17897dfb8c3"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.32/afk-linux-amd64.tar.gz"
      sha256 "fb5a418967b721c63e921493ea7bd9c712bcf132fd984bb8947c92d4c514019a"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.32/afk-linux-amd64.tar.gz"
    sha256 "fb5a418967b721c63e921493ea7bd9c712bcf132fd984bb8947c92d4c514019a"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.32/afk-linux-arm64.tar.gz"
    sha256 "d645f91cafdee70be332f6e7e5a50e6902d0b3409ed41c5cceb4c17897dfb8c3"
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
