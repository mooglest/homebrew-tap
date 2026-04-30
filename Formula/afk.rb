class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.3/afk-macos-arm64.tar.gz"
      sha256 "b618b8465af0344199a3a10c79d55af3890f7c2607d0af594e982440f0a58965"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.3/afk-linux-arm64.tar.gz"
      sha256 "99b7cec83498b7a5b937c3b560a7f84eb7233ae4d6df25fbab01c2fb610d547d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.3/afk-linux-amd64.tar.gz"
      sha256 "bb049d13edfd862719bc0590b8f7ae80fa09b73afc23ff87790ec019ac6bd200"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.3/afk-linux-amd64.tar.gz"
    sha256 "bb049d13edfd862719bc0590b8f7ae80fa09b73afc23ff87790ec019ac6bd200"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.3/afk-linux-arm64.tar.gz"
    sha256 "99b7cec83498b7a5b937c3b560a7f84eb7233ae4d6df25fbab01c2fb610d547d"
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
