# Nix Bun Template Project

A modern Nix flake template for Bun applications with automatic binary caching via Cachix.

## 🚀 Using This Template

### Create Your Own Project from This Template

#### Option 1: Use GitHub Template Feature (Recommended)

1. Click the **"Use this template"** button at the top of this repo
2. Choose **"Create a new repository"**
3. Name your new repository
4. Clone your new repo and follow the setup below

#### Option 2: Using Nix Flakes Directly

```bash
# Create a new project using this template
nix flake new my-project -t github:shedali/template-nix-project
cd my-project
```

### ⚙️ Setup Your New Project

After creating your repository from this template, customize it:

#### 1. Update Project Name

Edit `flake.nix`:

```nix
# Change these lines:
pname = "your-app-name";  # Line 19
description = "Your app description";  # Line 2
```

#### 2. Set Up Your Own Binary Cache (Optional but Recommended)

**Create a Cachix account:**

1. Go to [cachix.org](https://cachix.org) and sign in with GitHub
2. Create a new binary cache (e.g., `your-cache-name`)
3. Get your public key from the cache settings

**Update `flake.nix`:**

```nix
nixConfig = {
  substituters = [
    "https://cache.nixos.org"
    "https://your-cache-name.cachix.org"  # Replace
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "your-cache-name.cachix.org-1:YOUR_PUBLIC_KEY"  # Replace
  ];
};
```

**Update GitHub Actions workflows:**
Replace `bun-nix-example` with your cache name in:

- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `.github/workflows/cachix-deploy.yml`

**Add GitHub Secrets:**
Go to Settings → Secrets and variables → Actions, add:

- `CACHIX_AUTH_TOKEN` - Get from `cachix authtoken` command
- `CACHIX_SIGNING_KEY` - Get from your cache settings page

#### 3. Update Application Code

Replace `index.ts` with your actual application code.

#### 4. Handle Dependencies

When you add npm dependencies:

```bash
# Add a dependency
bun add express

# The lockfile (bun.lockb) is automatically updated
# Commit both package.json and bun.lockb

# CI will cache dependencies automatically
```

**Note**: The Nix build uses `bun build --compile` which bundles all dependencies into a single executable, so network access isn't needed during Nix builds.

#### 5. Update This README

Replace this template documentation with your project's documentation.

### 📋 Template Customization Checklist

- [ ] Update project name in `flake.nix`
- [ ] Create Cachix account and cache
- [ ] Update cache configuration in `flake.nix`
- [ ] Update cache name in GitHub workflows
- [ ] Add GitHub secrets (CACHIX_AUTH_TOKEN, CACHIX_SIGNING_KEY)
- [ ] Replace `index.ts` with your application
- [ ] Update this README with your project documentation
- [ ] Update LICENSE file with your information
- [ ] Push changes and verify CI passes

---

## Original Template Documentation

## Quick Start (Zero Config!)

```bash
# Clone and enter dev shell
git clone https://github.com/shedali/template-nix-project
cd template-nix-project
nix develop

# That's it! The cache is already configured in flake.nix
```

## Features

- 🚀 **Automatic Binary Caching** - Pre-built binaries download instantly
- 🛠️ **Development Shell** - Bun, Node.js, and dev tools pre-configured
- 📦 **Multiple Build Targets** - React SPA and server applications
- 🔧 **Linting Tools** - Nix formatting and style checking built-in
- 🪝 **Pre-commit Hooks** - Automatic code quality checks on git commits
- ⚡ **Hot Reload** - React development with Vite hot reload
- 🤖 **CI/CD Ready** - GitHub Actions with Cachix integration
- 🌍 **GitHub Pages** - Automatic deployment of React app to Pages

## Usage

### Development Environment

```bash
# Enter development shell (downloads from cache if available)
nix develop

# Available commands in dev shell:
start        # Start React development server
dev          # Start React dev server with hot reload (Vite)
build        # Build React app for production
build-server # Build server executable
preview      # Preview production build
test-server  # Test the running server
lint-check   # Check Nix code formatting
lint-fix     # Auto-fix Nix formatting
menu         # Show this menu again
```

### Building

#### React Static Site (Default)

```bash
# Build React app to static files
nix build
# or explicitly
nix build .#react

# Serve the built static files
./result/bin/serve

# The static files are in:
./result/www/
```

#### Server Application

```bash
# Build server executable (if you have server.ts)
nix build .#server

# Run the server
./result/bin/bun-app
```

#### Development Mode

```bash
# Enter dev shell and start Vite
nix develop
dev  # Starts Vite with hot reload

# Or use Bun's built-in server
bun --hot run index.tsx
```

### Project Structure

This template now supports both:

1. **React SPA** - Static site generation with React
2. **Server App** - Backend API or SSR (add `server.ts`)

The build automatically detects which type based on your files.

## Pre-commit Hooks

This template includes automatic pre-commit hooks that run on every git commit to ensure code quality:

### What Hooks Are Enabled

- **Nix**: `nixpkgs-fmt` (formatting) and `statix` (linting)
- **TypeScript/React**: `prettier` (formatting) and `eslint` (linting)
- **General**: Check for large files, merge conflicts, YAML syntax, trailing whitespace
- **Git**: Commitizen for conventional commit messages

### How It Works

1. **Automatic Installation**: Hooks install when you enter `nix develop`
2. **On Every Commit**: Hooks run automatically before each commit
3. **Manual Execution**: Run `pre-commit-run` to check all files

### Direnv Integration

With direnv installed:

```bash
# Automatically loads environment when entering directory
cd your-project
# 🚀 Development environment loaded!
# Pre-commit hooks will be installed automatically
```

### Configuration Files

- `.pre-commit-config.yaml` - Pre-commit hook configuration
- `.prettierrc` - Prettier formatting rules
- `.eslintrc.json` - ESLint rules for TypeScript/React

### Bypassing Hooks (Emergency Only)

```bash
# Skip hooks for emergency commits
git commit --no-verify -m "emergency fix"
```

## How Caching Works

This project uses [Cachix](https://cachix.org) for binary caching. The cache is **already configured** in `flake.nix`:

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

### What This Means for You

- ✅ **No manual setup required** - Cache configuration is embedded in the flake
- ⚡ **Instant builds** - If CI has built it, you download instead of compile
- 🔄 **Automatic fallback** - If cache miss, builds locally as normal
- 🔒 **Secure** - Public key verification ensures authenticity

### Trust Settings (One-Time Setup)

If you get a warning about untrusted substituters, you have two options:

#### Option A: Trust for this project only (Recommended)

```bash
# Answer 'y' when prompted:
nix develop --accept-flake-config
```

#### Option B: Trust permanently (Optional)

Add to `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```
extra-trusted-substituters = https://shedali.cachix.org
extra-trusted-public-keys = shedali.cachix.org-1:jnKOvnLAPbsv127ddEfluQ5Wo8h7llUT47CUJCumAvI=
```

## Project Structure

```
.
├── flake.nix           # Nix flake configuration with cache settings
├── index.ts            # Bun application entry point
├── docs/               # Documentation files
│   ├── CLAUDE.md       # Claude development instructions
│   ├── TEMPLATE_SETUP.md # Template setup guide
│   ├── CI_OPTIMIZATIONS.md # CI performance optimizations
│   └── CI_PARALLEL_JOBS.md # Parallel jobs implementation
├── .github/
│   └── workflows/
│       ├── ci.yml      # CI/CD pipeline with caching
│       ├── release.yml # Release builds
│       └── cachix-deploy.yml # Cache population
└── README.md           # This file
```

## Troubleshooting

### "Untrusted substituter" Warning

- **Solution**: Run `nix develop --accept-flake-config` or see Trust Settings above

### Slow First Build

- **Reason**: Cache miss - CI hasn't built this version yet
- **Solution**: Wait for CI to complete on main branch, then retry

### Verify Cache Usage

```bash
# Check if cache is configured
nix show-config | grep substituters

# Build with verbose output to see cache hits
nix build -L --print-build-logs
```

### Force Rebuild Without Cache

```bash
# Bypass cache for testing
nix build --option substituters ""
```

## Contributing

1. Fork and clone the repository
2. Make your changes
3. Test locally: `nix build`
4. Push to your fork
5. Open a pull request

CI will automatically build and test your changes. Once merged to main, the cache is automatically populated for all users.

## CI/CD Pipeline

The project includes GitHub Actions workflows that:

1. **On Pull Request**: Build and test (cache read-only)
2. **On Main Push**: Build and push to Cachix
3. **On Release**: Create platform-specific releases

### Setting Up Your Own Fork

If you fork this template for your own project:

1. Create your own cache at [cachix.org](https://cachix.org)
2. Update `flake.nix` with your cache name and public key
3. Add secrets to GitHub:
   - `CACHIX_AUTH_TOKEN` - From your Cachix account
   - `CACHIX_SIGNING_KEY` - From your cache settings
4. Update workflows to use your cache name

## License

MIT

## Credits

Built with:

- [Nix](https://nixos.org) - Reproducible builds and development environments
- [Bun](https://bun.sh) - Fast JavaScript runtime
- [Cachix](https://cachix.org) - Binary cache hosting
- [numtide/devshell](https://github.com/numtide/devshell) - Development shell framework
