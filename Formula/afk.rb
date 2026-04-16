class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.88"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.88/afk-macos-arm64.tar.gz"
      sha256 "97d913d4f639d2c542969e9a770ffb0a93e9444575756635f24d968c3ced1501"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.88/afk-linux-arm64.tar.gz"
      sha256 "7fab15c840e7844f300cd91eef2ad5ad6c8ace9b91994d051dc43ff5a9ec4532"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.88/afk-linux-amd64.tar.gz"
      sha256 "f213be73ef45009d5e6f3322337c0cf22e1f7c0a07220f4491785f1637c2e6d7"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.88/afk-linux-amd64.tar.gz"
    sha256 "f213be73ef45009d5e6f3322337c0cf22e1f7c0a07220f4491785f1637c2e6d7"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.88/afk-linux-arm64.tar.gz"
    sha256 "7fab15c840e7844f300cd91eef2ad5ad6c8ace9b91994d051dc43ff5a9ec4532"
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
