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

#### 4. Update This README
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
- 📦 **Multiple Build Targets** - Compiled and script variants
- 🔧 **Linting Tools** - Nix formatting and style checking built-in
- 🤖 **CI/CD Ready** - GitHub Actions with Cachix integration

## Usage

### Development Environment

```bash
# Enter development shell (downloads from cache if available)
nix develop

# Available commands in dev shell:
start       # Start the Bun application
dev         # Start with watch mode
build       # Build for production
test-server # Test the running server
lint-check  # Check Nix code formatting
lint-fix    # Auto-fix Nix formatting
menu        # Show this menu again
```

### Building

```bash
# Build the application (downloads from cache if available)
nix build

# Run the built application
./result/bin/bun-app

# Or run directly without building
nix run
```

### Alternative: Run TypeScript directly

```bash
# Run without compilation
nix run .#script
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