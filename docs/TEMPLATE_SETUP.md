# Using This Template for New Projects

## Quick Start

### Option 1: Nix Flake Template (Recommended)

```bash
# From GitHub
nix flake new my-project -t github:shedali/nix-build-test

# From local directory
nix flake new my-project -t /path/to/this/template
```

### Option 2: GitHub Template

1. Go to https://github.com/shedali/nix-build-test
2. Click "Use this template"
3. Create new repository
4. Clone your new repo

### Option 3: Manual Setup

```bash
git clone https://github.com/shedali/nix-build-test my-project
cd my-project
rm -rf .git
git init
```

## Customization Checklist

After creating your new project, customize these files:

### 1. Update `flake.nix`

- [ ] Line 2: Update description
- [ ] Line 48 & 97: Update `pname` to your project name
- [ ] Lines 7 & 11: Update Cachix cache name (or remove if not using)

### 2. Set Up Your Own Cachix (Optional)

```bash
# Create account at cachix.org
cachix generate-keypair my-cache-name

# Update flake.nix with your cache details
# Update .github/workflows/*.yml with your cache name
```

### 3. GitHub Repository Setup

```bash
# Initialize git
git init
git add .
git commit -m "Initial commit from template"

# Create GitHub repo and push
gh repo create my-project --public
git push -u origin main

# Add secrets (if using Cachix)
gh secret set CACHIX_AUTH_TOKEN
gh secret set CACHIX_SIGNING_KEY
```

### 4. Update Project Files

- [ ] Replace `README.md` with your project documentation
- [ ] Update `index.tsx` or `index.ts` with your code
- [ ] Delete `standalone.tsx` (it's for the template demo)
- [ ] Delete this `TEMPLATE_SETUP.md` file
- [ ] Update LICENSE with your name/organization

### 5. Choose Your Architecture

#### For React/Frontend App:

```bash
# Keep index.tsx, index.html, vite.config.ts
# Build with: nix build .#react
```

#### For Server/CLI App:

```bash
# Create server.ts
echo 'console.log("Hello from server");' > server.ts
# Build with: nix build .#server
```

#### For Simple Script:

```bash
# Use index.ts
# Run with: nix run .#script
```

### 6. Development Workflow

```bash
# Enter development environment
nix develop

# Install pre-commit hooks
install-hooks

# Start development
start  # or 'dev' for Vite

# Build for production
nix build
```

## Template Structure

```
.
├── flake.nix           # ← Main configuration
├── flake.lock          # ← Pinned dependencies
├── index.tsx           # ← React app (or replace)
├── index.ts            # ← Node/Bun script
├── standalone.tsx      # ← Demo file (delete this)
├── index.html          # ← HTML entry point
├── vite.config.ts      # ← Vite config
├── .github/
│   └── workflows/      # ← CI/CD pipelines
├── .envrc              # ← Direnv config
└── README.md           # ← Your documentation
```

## Common Customizations

### Remove React, Keep Simple Bun Script

```bash
rm index.tsx index.html vite.config.ts standalone.tsx
# Edit flake.nix to remove React build
```

### Add Database/Backend

```bash
# Create server.ts
cat > server.ts << 'EOF'
import { serve } from "bun";

serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello from Bun server!");
  },
});
EOF
```

### Add Dependencies

```bash
# For development (with network access)
bun add express

# For Nix builds, you'll need to:
# 1. Vendor dependencies, or
# 2. Set up Fixed Output Derivation (FOD)
```

## Tips

1. **Start simple**: Use the template as-is first, then customize
2. **Test locally**: `nix develop` before pushing
3. **Keep the structure**: The flake.nix organization works well
4. **Document changes**: Update README as you customize

## Getting Help

- Template issues: https://github.com/shedali/nix-build-test/issues
- Nix help: https://nixos.org/manual/nix/stable/
- Bun docs: https://bun.sh/docs
