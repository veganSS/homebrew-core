class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://docs.astral.sh/uv/"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.6.1.tar.gz"
  sha256 "70118971a2b6b7b6ac8e028b2505178b6a75ae77c314a60ff8403645e1ef7d78"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "45b88fc5c73ca181d23282a3a10c9113d7149ccfd7c3e454158c6e9af4b9f688"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2ba05bb6e3219010216ebfa22527f5e53fc2eaae5ad9efcaeaff4992cb38beb0"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "3aa3489efab8bfa0990be304b8fdd011f1d524f0cc39c430f323e5c954231a3c"
    sha256 cellar: :any_skip_relocation, sonoma:        "4d0b6156f34d34a2a6d775b0dfea2d8f032cb7500a003fd0faa91db05eb64a68"
    sha256 cellar: :any_skip_relocation, ventura:       "c9b81008e9545a564cfc7a51d358a1c46a287310f91f94ceaac667a3041516b0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1d9f1f28d5e9a24b3632ade66bccd4a0498d13c7b74f618b43b8ba714bc35f52"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "bzip2"
  uses_from_macos "xz"

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
    generate_completions_from_executable(bin/"uvx", "--generate-shell-completion")
  end

  test do
    (testpath/"requirements.in").write <<~REQUIREMENTS
      requests
    REQUIREMENTS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
