class Paqet < Formula
  desc "Bidirectional packet-level proxy using KCP and raw socket transport"
  homepage "https://github.com/hanselime/paqet"
  url "https://github.com/hanselime/paqet.git",
      tag:      "v1.0.0-alpha.19",
      revision: "09f2e0166067aa7747371f48347809930f2c8930"
  license "MIT"
  head "https://github.com/hanselime/paqet.git", branch: "main"

  depends_on "go" => :build
  depends_on "libpcap"

  def install
    ldflags = %W[
      -s -w
      -X paqet/cmd/version.Version=v#{version}
      -X paqet/cmd/version.GitTag=v#{version}
      -X paqet/cmd/version.GitCommit=#{Utils.git_short_head}
      -X paqet/cmd/version.BuildTime=#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}
    ]

    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd"
    pkgshare.install "example/client.yaml.example", "example/server.yaml.example"
  end

  def post_install
    (etc/"paqet").mkpath
    (var/"paqet").mkpath
    conf = etc/"paqet/config.yaml"
    conf.write (pkgshare/"client.yaml.example").read unless conf.exist?
  end

  service do
    run [opt_bin/"paqet", "run", "-c", etc/"paqet/config.yaml"]
    keep_alive true
    working_dir var/"paqet"
    log_path var/"log/paqet.log"
    error_log_path var/"log/paqet.log"
    require_root true
  end

  def caveats
    <<~EOS
      paqet requires root privileges for raw sockets.
      Edit #{etc}/paqet/config.yaml and set role/network values before starting.

      Start:
        sudo brew services start paqet

      Stop:
        sudo brew services stop paqet

      Example configs:
        #{opt_pkgshare}/client.yaml.example
        #{opt_pkgshare}/server.yaml.example
    EOS
  end

  test do
    output = shell_output("#{bin}/paqet version")
    assert_match "Version:    v#{version}", output
    assert_match "Platform:", output
  end
end
