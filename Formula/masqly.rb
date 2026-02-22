class Masqly < Formula
  desc "Local development with custom domains and TLS via dnsmasq and Caddy"
  homepage "https://github.com/arastu/masqly"
  url "https://github.com/arastu/masqly.git",
      tag:      "v1.0.0",
      revision: "0032036b28865daaa03709e31b8976342676fe98"
  license "MIT"
  head "https://github.com/arastu/masqly.git", branch: "main"

  depends_on "go" => :build
  depends_on "caddy"
  depends_on "dnsmasq"

  def install
    ldflags = "-s -w -X github.com/arastu/masqly/internal/version.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/masqly"
  end

  def caveats
    <<~EOS
      masqly requires dnsmasq and Caddy (installed as dependencies).

      macOS: sudo may be required for writing /etc/resolver/ (domain-specific DNS).
      Run `masqly start` first; if resolver write fails, run with sudo or create
      /etc/resolver manually.

      Data directory: ~/Library/Application Support/masqly
    EOS
  end

  test do
    assert_match "add", shell_output("#{bin}/masqly --help")
  end
end
