class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.81"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.81/afk-macos-arm64.tar.gz"
      sha256 "bb1857786898cbcaab1ffb18ec4efe2a07056e68242ea9fdd55765fcf94e89af"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.81/afk-linux-arm64.tar.gz"
      sha256 "39984fa0b8d2a017d05ba9e80df91ec7f08b089ec7876ce34a562c09cb4177bc"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.81/afk-linux-amd64.tar.gz"
      sha256 "b98de1f1df8305487f18b1c28a359f12e2b56a290294ca578a0fa33843b318c1"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.81/afk-linux-amd64.tar.gz"
    sha256 "b98de1f1df8305487f18b1c28a359f12e2b56a290294ca578a0fa33843b318c1"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.81/afk-linux-arm64.tar.gz"
    sha256 "39984fa0b8d2a017d05ba9e80df91ec7f08b089ec7876ce34a562c09cb4177bc"
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
