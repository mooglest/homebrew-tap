class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.39"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.39/afk-macos-arm64.tar.gz"
      sha256 "49498f94a4f1f04f0f12b1de04ece904e5f4bd32bee68e0e5b6caa4eb8135f97"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.39/afk-linux-arm64.tar.gz"
      sha256 "10741a656b9d94a65b374a0d0660f143b6f34c0f270275f652d25c44791c9160"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.39/afk-linux-amd64.tar.gz"
      sha256 "60631d947e99b91a38290df6df21bd657f9f665c2444b13d8a372312b10ae875"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.39/afk-linux-amd64.tar.gz"
    sha256 "60631d947e99b91a38290df6df21bd657f9f665c2444b13d8a372312b10ae875"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.39/afk-linux-arm64.tar.gz"
    sha256 "10741a656b9d94a65b374a0d0660f143b6f34c0f270275f652d25c44791c9160"
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
