class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.34"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.34/afk-macos-arm64.tar.gz"
      sha256 "cfd8e36e00027fcfea6986d3bb081042b4c71c2df89fac2ec9b824bdd846ab27"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.34/afk-linux-arm64.tar.gz"
      sha256 "fc9d696103fbf28c7788b17f849a112db86cdf6790942f079003b7ee9d178fa3"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.34/afk-linux-amd64.tar.gz"
      sha256 "f563a301cbfcb434144f98618e8270c8348c9bd9fc8275c2605ccd4a409fa113"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.34/afk-linux-amd64.tar.gz"
    sha256 "f563a301cbfcb434144f98618e8270c8348c9bd9fc8275c2605ccd4a409fa113"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.34/afk-linux-arm64.tar.gz"
    sha256 "fc9d696103fbf28c7788b17f849a112db86cdf6790942f079003b7ee9d178fa3"
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
