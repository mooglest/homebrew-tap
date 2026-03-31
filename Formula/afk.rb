class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.28"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.28/afk-macos-arm64.tar.gz"
      sha256 "119ac0cee4b617a38500c0644bdba62d5546f14b11e963aca8783a7acf6cb2f7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.28/afk-linux-arm64.tar.gz"
      sha256 "ad4cfcc35022739b89148ccb04557ac75ff942e159d387665fcbb1397d85ccd6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.28/afk-linux-amd64.tar.gz"
      sha256 "33c70a1bf951af0758f8681ab7a62766eb150986b2704c1add7f46954ef3851f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.28/afk-linux-amd64.tar.gz"
    sha256 "33c70a1bf951af0758f8681ab7a62766eb150986b2704c1add7f46954ef3851f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.28/afk-linux-arm64.tar.gz"
    sha256 "ad4cfcc35022739b89148ccb04557ac75ff942e159d387665fcbb1397d85ccd6"
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
