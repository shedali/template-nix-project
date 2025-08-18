# Claude Development Instructions

This file contains key information for Claude when working on this Nix Bun template project.

## Project Overview

This is a GitHub template repository for Bun applications built with Nix flakes. It provides:

- Automatic binary caching via Cachix
- Cross-platform CI/CD (Linux + macOS)
- Development shell with menu system
- Proper dependency management
- Template functionality for creating new projects

## Architecture

### Key Files

- `flake.nix` - Main Nix configuration with cache settings
- `index.ts` - Simple Bun application entry point
- `package.json` - Bun project metadata and dependencies
- `bun.lockb` - Dependency lockfile (binary format)
- `.github/workflows/` - CI/CD pipelines

### Build Strategy

- **Bun Compilation**: Uses `bun build --compile --outfile ./app` to create single executable
- **Dependencies**: GitHub Actions caches Bun deps, Nix builds use compiled executable
- **No FOD needed**: `--compile` bundles everything, no network access needed in Nix build

## Cachix Configuration

### Cache Details

- **Cache name**: `shedali`
- **URL**: `https://shedali.cachix.org`
- **Public key**: `shedali.cachix.org-1:jnKOvnLAPbsv127ddEfluQ5Wo8h7llUT47CUJCumAvI=`

### Required GitHub Secrets

- `CACHIX_AUTH_TOKEN` - For pushing to cache
- `CACHIX_SIGNING_KEY` - Alternative auth method

### Cache Configuration in flake.nix

```nix
nixConfig = {
  substituters = [
    "https://cache.nixos.org"
    "https://shedali.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "shedali.cachix.org-1:jnKOvnLAPbsv127ddEfluQ5Wo8h7llUT47CUJCumAvI="
  ];
};
```

## Development Environment

### Available Commands (in `nix develop`)

- `start` - Start the Bun application
- `dev` - Start with watch mode
- `build` - Build for production
- `test-server` - Test the running server with curl
- `lint-check` - Check Nix code formatting and style
- `lint-fix` - Auto-fix Nix formatting and style issues
- `menu` - Show command menu

### Tools Available

- `bun` - JavaScript runtime
- `nodejs` - For compatibility
- `nixpkgs-fmt` - Nix formatter
- `statix` - Nix linter

## CI/CD Pipeline

### Workflows

1. **ci.yml** - Main CI pipeline
   - Runs on Ubuntu + macOS
   - Caches Bun dependencies with `actions/cache@v4`
   - Installs deps with `bun install --frozen-lockfile`
   - Builds with Nix and pushes to Cachix
2. **release.yml** - Release builds on version tags
3. **cachix-deploy.yml** - Cache population on main branch

### GitHub Actions Setup

- Uses `oven-sh/setup-bun@v2` for Bun installation
- Uses `cachix/install-nix-action@v31` for Nix
- Uses `cachix/cachix-action@v14` for cache integration
- Caches Bun deps at `~/.bun/install/cache`

## Common Issues & Solutions

### Build Errors

- **"cannot use --compile with --outdir"**: Use `--outfile` instead of `--outdir` with `--compile`
- **"ConnectionRefused downloading tarball"**: Network access blocked - use `--compile` to bundle deps
- **"eDSRecordAlreadyExists"**: macOS runner has existing Nix users - use latest install-nix-action

### Cache Issues

- **"Binary cache doesn't exist"**: Check cache name matches in all workflows
- **Cache misses**: Verify public key is correct in flake.nix
- **Auth failures**: Check GitHub secrets are properly set

## Template Usage

### Creating New Projects

1. Click "Use this template" on GitHub, or
2. Use `nix flake new my-project -t github:shedali/template-nix-project`

### Customization Steps

1. Update project name in `flake.nix` (lines 2, 30)
2. Create own Cachix cache and update configuration
3. Add GitHub secrets for new cache
4. Replace `index.ts` with actual application code
5. Update README.md

## Dependency Management

### Adding Dependencies

```bash
bun add express  # Adds dependency and updates lockfile
git add package.json bun.lockb  # Commit both files
```

### How it Works

1. GitHub Actions installs deps outside Nix (cached)
2. `bun build --compile` bundles everything into single executable
3. Nix build uses the standalone executable (no network needed)
4. Result is cached in Cachix for others to use

## Testing Commands

### Local Testing

```bash
nix develop          # Enter dev shell
nix build           # Build (pulls from cache if available)
./result/bin/bun-app # Run built application
nix run             # Build and run in one command
```

### CI Status Checking

```bash
gh run list --limit 1                    # Latest run status
gh run view --log-failed                 # Failed run logs
gh run watch                             # Watch current run
```

## Troubleshooting

### Debug Build Issues

```bash
nix build -L                    # Verbose build output
nix log /nix/store/...          # Full build logs
nix build --option substituters ""  # Force rebuild without cache
```

### Cache Verification

```bash
nix show-config | grep substituters     # Check cache config
curl -s https://shedali.cachix.org/nix-cache-info  # Test cache access
```

### Development Shell Issues

```bash
nix develop --command bash -c "which bun"  # Test tool availability
nix develop --accept-flake-config           # Accept cache config
```

## Repository Status

This template is production-ready with:

- ✅ Working CI/CD on multiple platforms
- ✅ Proper Cachix integration
- ✅ Dependency caching
- ✅ Single executable builds
- ✅ Template functionality
- ✅ Development environment with tools

Last successful build: Run #16970170902 (all jobs passed)
