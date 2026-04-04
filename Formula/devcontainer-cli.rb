require "language/node"

class DevcontainerCli < Formula
  include Language::Node

  desc "Dev Containers CLI"
  homepage "https://github.com/devcontainers/cli"
  url "https://registry.npmjs.org/@devcontainers/cli/-/cli-0.85.0.tgz"
  sha256 "54cb822bc2218186458e5690f67b0116f6800c45f5cb14671285e704a2ee2c29"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/devcontainer --version 2>&1")
  end
end
