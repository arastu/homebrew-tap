class Paqet < Formula
  desc "Bidirectional packet-level proxy using KCP and raw socket transport"
  homepage "https://github.com/hanselime/paqet"
  url "https://github.com/hanselime/paqet.git",
      tag:      "v1.0.0-alpha.16",
      revision: "ccadb028fd15896228ae36645389888e0ebf486a"
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
  end

  test do
    output = shell_output("#{bin}/paqet version")
    assert_match "Version:    v#{version}", output
    assert_match "Platform:", output
  end
end
