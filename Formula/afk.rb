class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.64"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.64/afk-macos-arm64.tar.gz"
      sha256 "3c52e84a17d8bff02b28db6faadd627821eb53482565f2703509b54a4a710d41"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.64/afk-linux-arm64.tar.gz"
      sha256 "abd698cbf3609597951c07a0dc3d157da586c4411666dc97fa2a7f878eddaa85"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.64/afk-linux-amd64.tar.gz"
      sha256 "7146ea8d8ec66983cd7dc56e5007ef05933face34122d4e088a9360e6e64b918"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.64/afk-linux-amd64.tar.gz"
    sha256 "7146ea8d8ec66983cd7dc56e5007ef05933face34122d4e088a9360e6e64b918"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.64/afk-linux-arm64.tar.gz"
    sha256 "abd698cbf3609597951c07a0dc3d157da586c4411666dc97fa2a7f878eddaa85"
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
