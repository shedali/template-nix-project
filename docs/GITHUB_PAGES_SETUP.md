# GitHub Pages Deployment Setup

## What It Does

Automatically deploys your React app to GitHub Pages whenever you push to the main branch.

## Setup Required

### 1. Enable GitHub Pages (One-Time Setup)

Go to your GitHub repository settings:

1. **Navigate to Settings**:

   ```
   https://github.com/shedali/template-nix-project/settings/pages
   ```

2. **Configure Source**:
   - Source: "GitHub Actions"
   - ✅ NOT "Deploy from a branch"

3. **Save Settings**

### 2. Workflow Already Created

The `.github/workflows/pages.yml` workflow is already configured to:

- ✅ **Trigger**: On push to main branch
- ✅ **Build**: Uses Nix to build React app
- ✅ **Cache**: Uses Cachix + GitHub Actions cache
- ✅ **Deploy**: Uploads to GitHub Pages

## How It Works

### Deployment Flow

```bash
git push origin main
├── 🚀 Pages workflow triggers
├── 🔧 Nix builds React app
├── 📦 Uploads build to Pages
└── 🌍 Site live at https://shedali.github.io/template-nix-project
```

### Build Process

```yaml
Build React App:
├── nix build .#react -L
├── Copy result/www/* to _site/
├── Upload _site/ to GitHub Pages
└── Deploy automatically
```

## Expected Site URL

After setup, your React app will be available at:

```
https://shedali.github.io/template-nix-project
```

## First Deployment

1. **Push to trigger**:

   ```bash
   git add .github/workflows/pages.yml
   git commit -m "feat: add GitHub Pages deployment"
   git push origin main
   ```

2. **Check deployment**:
   - Go to Actions tab: https://github.com/shedali/template-nix-project/actions
   - Look for "Deploy to GitHub Pages" workflow
   - Should take ~1-2 minutes

3. **Visit site**:
   - URL will show in workflow output
   - Should see your React counter app

## Workflow Details

### Build Job

- **Environment**: Ubuntu latest
- **Nix Setup**: DeterminateSystems installer with Cachix
- **Caching**: GitHub Actions + Cachix for speed
- **Build**: `nix build .#react` → static files
- **Output**: Copies `result/www/*` to Pages artifact

### Deploy Job

- **Environment**: github-pages
- **Permissions**: pages:write, id-token:write
- **Process**: Uses official `actions/deploy-pages@v4`

## Customization

### Custom Domain

Add `CNAME` file to build output:

```nix
# In flake.nix reactApp installPhase:
echo "your-domain.com" > $out/www/CNAME
```

### Base Path (if repo name ≠ site path)

Update build to handle subpaths:

```nix
# If your site is at /some-path/ instead of /
sed -i 's|src="/standalone.js"|src="/repo-name/standalone.js"|' ./dist/index.html
```

## Troubleshooting

### Pages Not Enabled

- Error: "Pages not enabled"
- Solution: Enable in repo Settings → Pages → Source: GitHub Actions

### Build Failures

- Check Actions tab for errors
- Most common: Nix build failures or missing files
- Debug: Run `nix build .#react` locally first

### 404 on Site

- Check if `index.html` exists in artifact
- Verify Pages source is set to "GitHub Actions"
- Check deployment logs for errors

### Slow Deployments

- First deployment: ~2 minutes (no cache)
- Subsequent: ~30 seconds (with cache)
- Pre-push hook helps: builds locally → fast CI

## Security

- ✅ **Read-only**: Only deploys, doesn't access secrets
- ✅ **Isolated**: Uses GitHub's official deployment action
- ✅ **Permissions**: Minimal required permissions only

## Benefits

1. **Automatic**: Deploy on every main branch push
2. **Fast**: Uses Cachix + local caching
3. **Reliable**: Official GitHub Actions
4. **Free**: GitHub Pages hosting
5. **Custom domains**: Support for CNAME records

Your React app will now automatically deploy to GitHub Pages on every push to main!
