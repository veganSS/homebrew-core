class AwsCdk < Formula
  desc "AWS Cloud Development Kit - framework for defining AWS infra as code"
  homepage "https://github.com/aws/aws-cdk"
  url "https://registry.npmjs.org/aws-cdk/-/aws-cdk-2.1000.0.tgz"
  sha256 "f691fc07fb5e4c1f4cce640cd71f5cb6b50ce8cb3c2f33bb46d3fa1443fe0238"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "dcfce576c70fb7b85bf1d6f02b7e2073a7ba1214f1ed9d126e47e44f1c5b2536"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # `cdk init` cannot be run in a non-empty directory
    mkdir "testapp" do
      shell_output("#{bin}/cdk init app --language=javascript")
      list = shell_output("#{bin}/cdk list")
      cdkversion = shell_output("#{bin}/cdk --version")
      assert_match "TestappStack", list
      assert_match version.to_s, cdkversion
    end
  end
end
