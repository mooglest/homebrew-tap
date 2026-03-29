class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.4/afk-macos-arm64.tar.gz"
      sha256 "20a3b394881adda061679ef4530d0234356509baf46758099bc145dcb1d5e569"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.4/afk-linux-arm64.tar.gz"
      sha256 "ada8f6cac9382f349b0ecfbe547a733f34d2f80ffce6b6215edefdcc8e7f24f8"
    else
      url "https://github.com/mooglest/afk/releases/download/0.0.4/afk-linux-amd64.tar.gz"
      sha256 "f6f52e73759028d03f89a6fa58b479d13ce8133ee4de4bbebd42c5f1020a8040"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.4/afk-linux-amd64.tar.gz"
    sha256 "f6f52e73759028d03f89a6fa58b479d13ce8133ee4de4bbebd42c5f1020a8040"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.4/afk-linux-arm64.tar.gz"
    sha256 "ada8f6cac9382f349b0ecfbe547a733f34d2f80ffce6b6215edefdcc8e7f24f8"
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
