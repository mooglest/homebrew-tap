class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.56"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.56/afk-macos-arm64.tar.gz"
      sha256 "59bd03bc56db53a02d5b60cc2500cf4fabee286356c84c4845e3bd7066692e26"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.56/afk-linux-arm64.tar.gz"
      sha256 "be9250405b8761c9be2169273d92dc7048e0f1ddc075ec3417e6980284c9d185"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.56/afk-linux-amd64.tar.gz"
      sha256 "1ab072a8a9e8d3ce8b9549f029e76b84f4f0089a96b242752e83c549088ef65f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.56/afk-linux-amd64.tar.gz"
    sha256 "1ab072a8a9e8d3ce8b9549f029e76b84f4f0089a96b242752e83c549088ef65f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.56/afk-linux-arm64.tar.gz"
    sha256 "be9250405b8761c9be2169273d92dc7048e0f1ddc075ec3417e6980284c9d185"
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
