class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.13"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.13/afk-macos-arm64.tar.gz"
      sha256 "f6b5f314195595a7c4ff6584fcac56509defd47efe967ddea85438e2be196024"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.13/afk-linux-arm64.tar.gz"
      sha256 "84b13bf2a642de6182ae20393a3832e9792577aedd50d7f6cd89d5b4984a1edb"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.13/afk-linux-amd64.tar.gz"
      sha256 "2cf04ca3ac08c1d569eed1af9ef66dc1600d0ec394d883e7ea842933cd23d7d2"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.13/afk-linux-amd64.tar.gz"
    sha256 "2cf04ca3ac08c1d569eed1af9ef66dc1600d0ec394d883e7ea842933cd23d7d2"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.13/afk-linux-arm64.tar.gz"
    sha256 "84b13bf2a642de6182ae20393a3832e9792577aedd50d7f6cd89d5b4984a1edb"
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
