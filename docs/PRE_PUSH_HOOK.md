# Pre-Push Cachix Hook

## What It Does

The pre-push git hook automatically pre-populates Cachix cache before you push source changes, making CI **70% faster**.

## How It Works

### **Before Push**

```bash
git push
├── 🔍 Check for source changes (not just docs)
├── 🏗️ Build all targets locally (if source changed)
├── ☁️ Push builds to Cachix
└── ✅ Continue with git push
```

### **Then CI Runs**

```bash
CI: nix build .#react
├── ✅ Found in Cachix (your pre-pushed build)
├── ⬇️ Download (~5s instead of building ~60s)
└── 🚀 CI completes in ~30s instead of 2+ minutes
```

## Prerequisites

1. **Cachix Auth Token**: Must have `CACHIX_AUTH_TOKEN` set
2. **Source Changes**: Only runs for non-documentation changes
3. **Successful Builds**: Blocks push if builds fail

## Hook Behavior

### **Documentation-Only Changes**

```bash
$ git push
🚀 Pre-push hook: Checking for source changes...
📁 Checking for source file changes...
✅ Only documentation changes detected, skipping cache population
```

### **Source Code Changes**

```bash
$ git push
🚀 Pre-push hook: Checking for source changes...
📁 Checking for source file changes...
🔨 Source changes detected, pre-building for Cachix...
🔐 Authenticating with Cachix...
🏗️ Building all targets...
   Building React app...
   ✅ React app built successfully
   Building server...
   ✅ Server built successfully
   Building script...
   ✅ Script built successfully
☁️ Pushing builds to Cachix cache...
   Pushing result...
   ✅ Pushed result
   Pushing result-1...
   ✅ Pushed result-1
   Caching development shell...
   ✅ Development shell cached

🚀 Cache fully populated - CI should be very fast!
✅ Pre-push cache population complete
```

### **Build Failures**

```bash
$ git push
🚀 Pre-push hook: Checking for source changes...
🏗️ Building all targets...
   Building React app...
   ❌ React app build failed
❌ Some builds failed. Fix errors before pushing.
# Push is blocked until you fix the build
```

### **No Auth Token**

```bash
$ git push
🚀 Pre-push hook: Checking for source changes...
⚠️ CACHIX_AUTH_TOKEN not set, skipping cache pre-population
   (CI will still work, but will be slower)
# Push continues normally
```

## Performance Impact

| Scenario          | Hook Time    | CI Time  | Total Benefit     |
| ----------------- | ------------ | -------- | ----------------- |
| **Docs only**     | 0s (skipped) | ~10s     | Same              |
| **Source + hook** | ~30-60s      | ~30s     | **70% faster CI** |
| **No hook**       | 0s           | ~2+ mins | Baseline          |

## Files Built and Cached

The hook builds and caches:

- `nix build .#react` → React static site
- `nix build .#server` → Server executable
- `nix build .#script` → Script wrapper
- `nix develop` → Development shell dependencies

## Troubleshooting

### Hook Not Running

```bash
# Check if hook exists and is executable
ls -la .git/hooks/pre-push
# Should show: -rwxr-xr-x ... pre-push
```

### Slow Local Builds

```bash
# Check if you have good local cache
nix build .#react  # Should be ~1 second
```

### Auth Issues

```bash
# Verify token is set
echo $CACHIX_AUTH_TOKEN  # Should show actual token, not op://...

# Test Cachix auth
cachix authtoken $CACHIX_AUTH_TOKEN
```

### Skip Hook (Emergency)

```bash
# Skip hook for this push only
git push --no-verify

# Or disable hook temporarily
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
```

## Benefits

1. **Faster CI**: 70% reduction in CI time for source changes
2. **Team Benefits**: Others get your pre-built dependencies
3. **Early Failure**: Catches build issues before CI
4. **Smart**: Only runs for source changes, not docs
5. **Safe**: Continues push even if cache fails

The hook makes your development workflow faster while ensuring CI speed for everyone!
