# Reliable Nix Caching Strategy

## Problem with Magic Nix Cache

`DeterminateSystems/magic-nix-cache-action@v2` often fails in CI with:

- Permission errors
- Network timeouts
- Unreliable cache hits
- "Failed to save" tar errors

## New Approach: Multi-Layer Caching

### 1. Direct Nix Configuration

```yaml
- uses: DeterminateSystems/nix-installer-action@v4
  with:
    extra-conf: |
      extra-substituters = https://cache.nixos.org https://shedali.cachix.org
      extra-trusted-public-keys = ...
      max-jobs = auto
      cores = 0
```

**Benefits:**

- ✅ No magic cache middleware
- ✅ Direct Cachix integration
- ✅ Better reliability
- ✅ Optimized build parallelism

### 2. GitHub Actions Cache (Targeted)

```yaml
- name: Cache Nix store paths
  uses: actions/cache@v4
  with:
    path: |
      ~/.cache/nix
      /nix/var/nix/profiles
      /nix/var/nix/gcroots
    key: nix-${{ runner.os }}-${{ hashFiles('flake.lock', '**/*.nix') }}
```

**What We Cache:**

- `~/.cache/nix`: User-level Nix cache
- `/nix/var/nix/profiles`: Installed profiles
- `/nix/var/nix/gcroots`: Garbage collection roots

**What We Don't Cache:**

- `/nix/store`: Too large, relies on Cachix instead

### 3. Pre-population Strategy

```yaml
- name: Pre-populate Nix store
  run: |
    nix build nixpkgs#hello --no-link  # Test cache connectivity
    nix develop --command echo "Dev shell ready"  # Pre-build dev deps
```

**Purpose:**

- Warm up the Nix daemon
- Test Cachix connectivity
- Pre-build development shell
- Populate common dependencies

## Cache Hierarchy

1. **GitHub Actions Cache** (~5-10s restore)
   - Profiles and gcroots
   - Cross-job persistence
2. **Cachix Binary Cache** (~15-30s download)
   - Pre-built derivations
   - Global availability
3. **Local Build** (fallback)
   - Only if cache misses
   - Still fast due to bundled approach

## Performance Expectations

### First Run (Cache Miss)

```
Setup: 30s
Cache restore: 0s (miss)
Cachix downloads: 30-60s
Builds: 5-10s
Total: ~1.5 minutes
```

### Subsequent Runs (Cache Hit)

```
Setup: 30s
Cache restore: 10s
Cachix downloads: 0s (cached)
Builds: 2-5s
Total: ~45 seconds
```

### With Docs-Only Fast Path

```
Path detection: 5s
Skip all builds: 0s
Total: ~5 seconds
```

## Troubleshooting

### Cache Not Working

1. Check Cachix connectivity: `nix build nixpkgs#hello`
2. Verify cache keys in logs
3. Check GitHub Actions cache limits (2GB)

### Still Slow Builds

1. Verify source filtering is working
2. Check for unnecessary rebuilds
3. Monitor cache hit ratios

### macOS Issues

- Cache paths may differ
- Permissions can be different
- Consider Ubuntu-only for PRs

## Migration Benefits

| Component        | Before         | After          |
| ---------------- | -------------- | -------------- |
| **Magic Cache**  | Unreliable     | Removed        |
| **GitHub Cache** | `/nix` (fails) | Targeted paths |
| **Cachix**       | Secondary      | Primary        |
| **Setup Time**   | 3+ minutes     | ~45 seconds    |
| **Reliability**  | Poor           | High           |

The new strategy prioritizes reliability over theoretical speed, resulting in faster real-world performance.
