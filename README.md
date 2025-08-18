# Nix + Bun + React Template

[![CI Status](https://github.com/shedali/nix-build-test/actions/workflows/ci.yml/badge.svg)](https://github.com/shedali/nix-build-test/actions/workflows/ci.yml)

A minimal, reproducible Nix flake template for Bun and React applications with comprehensive CI/CD.

## Features

- 🚀 **Minimal setup** - Only 3 core files (flake.nix, index.html, flake.lock)
- ⚡ **Fast CI** - Extensive caching with Cachix for instant builds
- 🔄 **Bit-for-bit reproducible** - Guaranteed same output locally and in CI
- 🪝 **Auto-formatting** - Pre-commit hooks auto-format on commit
- 📦 **Binary caching** - Share builds across team with Cachix
- 🌐 **GitHub Pages** - Auto-deploy React app

## Quick Start

```bash
# Clone the template
git clone https://github.com/shedali/nix-build-test
cd nix-build-test

# Enter development environment
nix develop

# Start dev server
dev

# Build for production
nix build

# Run production build
nix run
```

## CI/CD Pipeline

### Workflows

1. **CI** (`ci.yml`)
   - Format checking
   - Multi-platform builds (Linux + macOS)
   - Reproducibility verification
   - Cachix binary cache population
   - Performance metrics

2. **GitHub Pages** (`pages.yml`)
   - Auto-deploy React app on main branch pushes
   - Uses Cachix for fast builds

3. **Dependency Updates**
   - **Automated Weekly** (`update-flake.yml`) - Every Monday at 3 AM UTC
   - **Manual Single Input** (`update-single-input.yml`) - Update specific dependencies
   - **Dependabot** (`.github/dependabot.yml`) - GitHub Actions updates
   - Creates PRs with detailed changelogs
   - Auto-assigns and labels PRs

### Cachix Setup

To enable Cachix in your fork:

1. Create account at https://cachix.org
2. Create a binary cache
3. Add secret to GitHub: `CACHIX_AUTH_TOKEN`
4. Update cache name in workflows and flake.nix

### Local Cachix Setup

```bash
# Install Cachix
nix-env -iA nixpkgs.cachix

# Configure your cache
cachix use your-cache-name
cachix authtoken your-token

# Push builds automatically (pre-push hook)
nix develop
install-pre-push
export CACHIX_CACHE=your-cache-name
```

## Reproducibility

The build system ensures bit-for-bit reproducibility:

- Same Nix derivation hash = same output
- CI verifies reproducibility on every build
- Cachix ensures everyone gets identical binaries
- No "works on my machine" issues

## Development

```bash
# Enter dev environment (auto-installs pre-commit hooks)
nix develop

# Available commands
menu              # Show all commands
dev               # Start dev server
build             # Build application
serve             # Build and serve
format            # Format all files
setup-cachix      # Configure Cachix
install-pre-push  # Install pre-push hook
```

## Project Structure

```
.
├── flake.nix          # Nix configuration
├── flake.lock         # Locked dependencies
├── index.html         # React app (inline)
├── .github/
│   └── workflows/     # CI/CD pipelines
└── README.md          # This file
```

## Performance

- **Local builds**: < 1 second (cached)
- **CI builds**: < 2 minutes (with Cachix)
- **Cold CI builds**: < 5 minutes (no cache)

## License

MIT
