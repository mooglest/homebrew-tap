class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.90"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.90/afk-macos-arm64.tar.gz"
      sha256 "08959b39bbdd4a7c46b369d1efab6ac0b05624d4255aca26f86f34d4f35d58aa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.90/afk-linux-arm64.tar.gz"
      sha256 "4fff498b9b1ae6848f3a18e5d158d1bb39cd4fe78519180658cd82b8a37cb6f1"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.90/afk-linux-amd64.tar.gz"
      sha256 "5df64cc4e86b8e9ca316f146635c28c65fa4d87d71ff6d807e6cf5981593780f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.90/afk-linux-amd64.tar.gz"
    sha256 "5df64cc4e86b8e9ca316f146635c28c65fa4d87d71ff6d807e6cf5981593780f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.90/afk-linux-arm64.tar.gz"
    sha256 "4fff498b9b1ae6848f3a18e5d158d1bb39cd4fe78519180658cd82b8a37cb6f1"
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
