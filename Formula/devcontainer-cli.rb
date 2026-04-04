require "language/node"

class DevcontainerCli < Formula
  include Language::Node

  desc "Dev Containers CLI"
  homepage "https://github.com/devcontainers/cli"
  url "https://registry.npmjs.org/@devcontainers/cli/-/cli-0.85.0.tgz"
  sha256 "54cb822bc2218186458e5690f67b0116f6800c45f5cb14671285e704a2ee2c29"
  license "MIT"

  bottle do
    root_url "https://github.com/get2knowio/homebrew-tap/releases/download/devcontainer-cli-0.85.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d690d6891ac25d91f2c9a1b54826c6559dee6325331608ab54507c2a2f50c403"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/devcontainer --version 2>&1")
  end
end
