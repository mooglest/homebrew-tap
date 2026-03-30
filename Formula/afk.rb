class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.23"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.23/afk-macos-arm64.tar.gz"
      sha256 "2e596d75e2dbef52ea6e60c75a46674850031196bef4c7b2be1cdb15d9461955"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.23/afk-linux-arm64.tar.gz"
      sha256 "a446cfb61b3d012f839453f8479e5c9c7ae1c2e8d484cf688149c8a1cb912fd3"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.23/afk-linux-amd64.tar.gz"
      sha256 "c6800821e709ed5c4f6cdde202e5f574433d95dde14420ea4dfdb1547a467aba"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.23/afk-linux-amd64.tar.gz"
    sha256 "c6800821e709ed5c4f6cdde202e5f574433d95dde14420ea4dfdb1547a467aba"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.23/afk-linux-arm64.tar.gz"
    sha256 "a446cfb61b3d012f839453f8479e5c9c7ae1c2e8d484cf688149c8a1cb912fd3"
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
