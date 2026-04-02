require "language/node"

class Qmd < Formula
  include Language::Node

  desc "Mini CLI search engine for docs, knowledge bases, and meeting notes"
  homepage "https://github.com/tobi/qmd"
  url "https://registry.npmjs.org/@tobilu/qmd/-/qmd-2.0.1.tgz"
  sha256 "4f7156f50decebee8422f5e49e1b8b42db08b37b8e33446d83b28e391875a979"
  license "MIT"

  bottle do
    root_url "https://github.com/get2knowio/homebrew-tap/releases/download/qmd-2.0.1"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "12cb9031e23bee528bb08c6b8adce12b9233cc063cb171da892194598a9350f4"
  end

  depends_on "cmake" => :build
  depends_on "node"

  def install
    system "npm", "install", *std_npm_args(ignore_scripts: false)
    (bin/"qmd").write_env_script libexec/"bin/qmd", PATH: "#{Formula["node"].opt_bin}:$PATH"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/qmd --version")
  end
end
