class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.50"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.50/afk-macos-arm64.tar.gz"
      sha256 "424fc809291ed8429823878a0ac41f9034fc4f81ff57e9bcd938d390421a8530"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.50/afk-linux-arm64.tar.gz"
      sha256 "78d0962c6a16d5fe7fbf872bc6d30250074291dc9ef5e8be2cd158ede5b25114"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.50/afk-linux-amd64.tar.gz"
      sha256 "69db12298ba5bc0a1e25b2da6080306647d124fc62df45bf52241dfcd96a4b99"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.50/afk-linux-amd64.tar.gz"
    sha256 "69db12298ba5bc0a1e25b2da6080306647d124fc62df45bf52241dfcd96a4b99"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.50/afk-linux-arm64.tar.gz"
    sha256 "78d0962c6a16d5fe7fbf872bc6d30250074291dc9ef5e8be2cd158ede5b25114"
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
