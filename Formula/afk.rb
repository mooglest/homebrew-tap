class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.9"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.9/afk-macos-arm64.tar.gz"
      sha256 "e10b8c7a111393afe58412f3bd8b9f23e4e055fbdd547811a73a52ed208a68c6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.9/afk-linux-arm64.tar.gz"
      sha256 "80b7b9b4b19da8b90208efffbcddb917a91f324b575c9a75219dbb6275033dc9"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.9/afk-linux-amd64.tar.gz"
      sha256 "34e50ec6639b5b9dcb5cddf1837bc4d58299f08955b66e16eb6e0f9a93097dbe"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.9/afk-linux-amd64.tar.gz"
    sha256 "34e50ec6639b5b9dcb5cddf1837bc4d58299f08955b66e16eb6e0f9a93097dbe"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.9/afk-linux-arm64.tar.gz"
    sha256 "80b7b9b4b19da8b90208efffbcddb917a91f324b575c9a75219dbb6275033dc9"
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
