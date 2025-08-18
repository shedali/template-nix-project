# Nix + Bun + React Template

[![CI](https://github.com/shedali/nix-build-test/actions/workflows/ci.yml/badge.svg)](https://github.com/shedali/nix-build-test/actions/workflows/ci.yml)

Minimal Nix flake for Bun and React with fast CI.

## Usage

```bash
nix develop    # Enter dev shell
dev            # Start dev server
nix build      # Build app
nix run        # Build and serve
```

## Features

- 🚀 Sub-30s CI with Cachix
- 🪝 Auto-formatting pre-commit hooks
- 📦 GitHub Pages deployment
- 🔄 Weekly dependency updates

## Setup

1. Fork this repo
2. Add `CACHIX_AUTH_TOKEN` secret
3. Update cache name in workflows and flake.nix
4. Push and enjoy fast builds!
