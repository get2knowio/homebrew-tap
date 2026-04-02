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
brew fetch --force --bottle-disable Formula/<name>.rb
# or
curl -L <url> | shasum -a 256

# Lint formula style
brew style Formula/<name>.rb

# Auto-fix style issues
brew style --fix Formula/<name>.rb
```

## Updating a formula to a new version

1. Update `url` to point to the new release tarball
2. Update `sha256` (use `curl -L <url> | shasum -a 256`)
3. Run `brew audit Formula/<name>.rb` and `brew style Formula/<name>.rb`
4. Run `brew install --build-from-source Formula/<name>.rb && brew test Formula/<name>.rb`
