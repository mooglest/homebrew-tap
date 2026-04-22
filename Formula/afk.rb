class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.28"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.28/afk-macos-arm64.tar.gz"
      sha256 "8b4546e42525bdce601bac83a70f0141cbd9dc1f6ce600de0372e57d4705d44a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.28/afk-linux-arm64.tar.gz"
      sha256 "c5b28fbc0246e5ef07795318190bcb87c6e03f771b90f5bb24d2e5a32d38efd6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.28/afk-linux-amd64.tar.gz"
      sha256 "9dbadef8ae4d920857431a689412e70f6527d4446c11ba9fd63731f9e96eb0be"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.28/afk-linux-amd64.tar.gz"
    sha256 "9dbadef8ae4d920857431a689412e70f6527d4446c11ba9fd63731f9e96eb0be"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.28/afk-linux-arm64.tar.gz"
    sha256 "c5b28fbc0246e5ef07795318190bcb87c6e03f771b90f5bb24d2e5a32d38efd6"
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
