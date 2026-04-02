# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [Homebrew tap](https://docs.brew.sh/Taps) — a third-party repository of formula and cask definitions that Homebrew can install from. Users add it with:

```
brew tap <owner>/tap
```

Then install packages with `brew install <owner>/tap/<formula>`.

## Repository structure

- `Formula/` — Ruby `.rb` files, one per installable CLI tool or library
- `Casks/` — Ruby `.rb` files for macOS GUI apps (if applicable)
- Formula files follow Homebrew's DSL; each defines a `class` inheriting from `Formula`

## Formula authoring

Each formula file lives at `Formula/<name>.rb` and looks like:

```ruby
class Name < Formula
  desc "Short description"
  homepage "https://example.com"
  url "https://github.com/owner/repo/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  def install
    bin.install "name"
  end

  test do
    system "#{bin}/name", "--version"
  end
end
```

## Common commands

```bash
# Audit a formula for style and correctness
brew audit --new Formula/<name>.rb

# Test a formula locally before committing
brew install --build-from-source Formula/<name>.rb
brew test Formula/<name>.rb

# Get the sha256 for a URL (needed when adding/updating a formula)
curl -L <url> | shasum -a 256

# Regenerate all resource blocks after a version bump (Python formulae)
brew update-python-resources Formula/<name>.rb

# Lint formula style
brew style Formula/<name>.rb

# Auto-fix style issues
brew style --fix Formula/<name>.rb
```

## Updating a formula to a new version

1. Update `url` to point to the new release tarball
2. Update `sha256` (use `curl -L <url> | shasum -a 256`)
3. For Python formulae, run `brew update-python-resources Formula/<name>.rb` to regenerate resource blocks
4. Run `brew audit Formula/<name>.rb` and `brew style Formula/<name>.rb`
5. Run `brew install --build-from-source Formula/<name>.rb && brew test Formula/<name>.rb`

## Bottling workflow (CI)

Changes go through PRs, not direct pushes to `main`. The flow:

1. Push changes on a branch, open a PR
2. `tests.yml` runs `brew test-bot` — builds bottles and uploads them as artifacts
3. When CI is green, apply the `pr-pull` label to the PR
4. `publish.yml` runs `brew pr-pull` — downloads artifacts, creates a GitHub Release with the bottle attached, updates the `bottle do` block in the formula, pushes to `main`, and closes the PR

Do **not** merge the PR normally — the `pr-pull` label is what triggers publishing.

## Python formulae

- Use `include Language::Python::Virtualenv` and `virtualenv_install_with_resources`
- Declare every transitive dependency as a `resource` block with its PyPI sdist URL and sha256
- Use `brew update-python-resources` to auto-regenerate resource blocks after version bumps
- **Verify all PyPI URLs** — path hashes in PyPI URLs can have typos; confirm with `curl -L <url> | shasum -a 256`
- **pydantic-core must be pinned to the exact version pydantic requires** — do not use the latest pydantic-core independently; check the pydantic release's `requires_dist` for the exact pin
- **Runtime linkage deps**: add `depends_on "openssl@3"` when `cryptography` is in the dep tree; add `depends_on "libyaml"` when `pyyaml` is in the dep tree
- Formulae with `pydantic-core`, `rpds-py`, or `cryptography` require `depends_on "rust" => :build` and `depends_on "pkgconf" => :build`

## Node/npm formulae

- Use `require "language/node"` at the top of the file and `include Language::Node`
- `std_npm_args` takes no arguments — pass the prefix separately: `system "npm", "install", "--prefix=#{libexec}", *std_npm_args`
- For TypeScript packages: prefer the npm registry tarball over the GitHub source tarball when the npm tarball includes pre-built `dist/` — avoids needing TypeScript as a build dep
- Check whether the package's `bin` script uses `node` or `bun` at runtime; the npm tarball won't have a `bun.lock`, so the script will fall back to `node` automatically

## CI gotchas

- `brew test-bot --only-tap-syntax` scans **all files** in the tap, not just `.rb` files — any `sha256` value in CLAUDE.md or other docs must be a valid 64-char hex string
- `brew test-bot` only builds bottles for formulae that changed in the PR (detected by git diff), but runs syntax checks across the whole tap
- `macos-15-xlarge` (Intel) is a paid GitHub Actions runner — the workflow uses `macos-15` (ARM) only to stay on the free tier
- Before writing a formula test, verify what flags the CLI actually supports — not all tools have `--version`; use `--help` and `assert_match` against known output instead
