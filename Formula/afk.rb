class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.8"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.8/afk-macos-arm64.tar.gz"
      sha256 "803d066746ce915f7ddc91a8cf3e5897d8b8feca4b3e9214347ab5d4c406e941"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.8/afk-linux-arm64.tar.gz"
      sha256 "8d0fc2fe4cb1fb70f875913fd9c3fde06f14ab665a05fc1446498aa8cd26d902"
    else
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.8/afk-linux-amd64.tar.gz"
      sha256 "a48bb31d1c78d6253099ac0f49a92794a12fb8da781eab4fc45628dba590aa5e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.8/afk-linux-amd64.tar.gz"
    sha256 "a48bb31d1c78d6253099ac0f49a92794a12fb8da781eab4fc45628dba590aa5e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.8/afk-linux-arm64.tar.gz"
    sha256 "8d0fc2fe4cb1fb70f875913fd9c3fde06f14ab665a05fc1446498aa8cd26d902"
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
