# Claude Instructions - Bun + React + Nix Template

## Project Overview

This is a minimal, high-performance template for building React applications with Bun and Nix. The template focuses on:

- **Bun** for TypeScript/TSX compilation and serving
- **React** with proper state management (useState, createRoot)
- **Nix Flakes** for reproducible builds with Fixed Output Derivation (FOD)
- **Cachix** binary caching for fast CI/CD
- **GitHub Actions** optimized CI/CD pipeline
- **Pre-commit/pre-push hooks** for code quality

## Architecture Decisions

### Build System

- **FOD (Fixed Output Derivation)** for handling React dependencies
  - Allows `bun install` in Nix sandbox with network access
  - Hash: `sha256-eX+2TYc2uI88XLY6Azuv+SxWxROHjD/ilZXIvVB9Loc=`
  - Must update hash when dependencies change in package.json
- **Two-stage build**: `deps` derivation + `app` derivation
- **Cachix integration** for binary caching (cache: `shedali`)

### Development Workflow

- **direnv** with `.envrc` sets `NIX_CONFIG="accept-flake-config = true"`
- **DevShell commands**: `dev`, `build`, `serve`, `format`, `update-hash`
- **Automatic dependency installation** via `bun install` on shell startup
- **Pre-commit hooks** auto-format code, pre-push hooks verify build + push to Cachix

### File Structure

```
src/main.tsx          # React app with useState hook
index.html            # Dev template (references src/main.tsx)
build.html            # Prod template (references main.js)
package.json          # React dependencies
flake.nix             # Nix build configuration
.envrc                # direnv config with NIX_CONFIG
```

## Key Commands

### DevShell Menu

- `dev` - Start Bun dev server (`bunx serve . -p 3000`)
- `build` - Build static output (`bun build + cp build.html`)
- `serve` - Serve built output (`bunx serve ./dist -p 3000`)
- `format` - Format files (`nixpkgs-fmt + prettier`)
- `update-hash` - Auto-update FOD hash when dependencies change

### Hash Update Process

When package.json dependencies change:

1. Run `update-hash` command in devshell
2. OR manually: reset hash to zeros → `nix build` → copy new hash from error

### CI/CD Pipeline

- **CI**: Format check, build, flake check (all with `--accept-flake-config`)
- **Pages**: Deploys only after CI succeeds (`workflow_run` trigger)
- **Cachix**: Automatic binary cache population via pre-push hooks
- **Magic Nix Cache**: Deprecated (removed Feb 1, 2025)

## Template Philosophy

- **Minimal line count** - stripped to essentials
- **No external tooling** - pure Bun + Nix + React
- **Reproducible builds** - FOD + Cachix ensure bit-for-bit reproducibility
- **Fast CI** - under 30 seconds with proper caching
- **Developer experience** - automatic setup, no manual configuration

## Critical Files to Preserve

- `flake.nix` - Complete build configuration with FOD
- `.envrc` - Sets `NIX_CONFIG="accept-flake-config = true"`
- `src/main.tsx` - Clean React component with useState
- `.github/workflows/` - Optimized CI/CD with Cachix integration
- `.git/hooks/pre-push` - Build verification + Cachix upload

## Environment Variables

- `CACHIX_AUTH_TOKEN` - For cache uploads (CI + maintainers only)
- `CACHIX_CACHE=shedali` - Cache name
- `NIX_CONFIG="accept-flake-config = true"` - Auto-accept flake config

## Troubleshooting

- **FOD hash mismatch**: Run `update-hash` command
- **Substituter warnings**: Ensure `.envrc` is loaded by direnv
- **Dependency issues**: Check if `bun.lockb` needs updating
- **CI failures**: Usually FOD hash or network access issues

## Template Evolution

Started as complex CI template → stripped to bare bones → added proper React with FOD → optimized for performance. Current state represents minimal viable template with full React/Bun/Nix integration.

## Notes for Future Development

- Keep template minimal - resist adding unnecessary features
- FOD hash must be updated when dependencies change
- All nix commands should use `--accept-flake-config` or set NIX_CONFIG
- Binary caching is critical for performance
- DevShell commands should be self-explanatory and fast
