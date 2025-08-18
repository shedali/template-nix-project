# CI Performance Monitoring

This project includes comprehensive CI performance monitoring to ensure build times don't regress over time.

## 📊 Monitoring Tools

### 1. **Automated Performance Tracking**

- **Location**: `.github/workflows/perf-monitor.yml`
- **Trigger**: After every CI run + daily at 6 AM UTC
- **Purpose**: Tracks CI duration trends and alerts on regressions

### 2. **Performance Report Script**

- **Command**: `ci-perf` (or `./scripts/ci-perf-report.sh`)
- **Purpose**: Generate detailed performance analytics
- **Data**: Last 30 days of CI runs with statistics and trends

### 3. **Real-time CI Status**

- **Command**: `ci-status`
- **Purpose**: Quick check of recent CI runs and their status

## 🎯 Performance Thresholds

| Metric        | Target       | Warning        | Critical    |
| ------------- | ------------ | -------------- | ----------- |
| Total CI Time | < 3 minutes  | 3-5 minutes    | > 5 minutes |
| React Build   | < 60 seconds | 60-120 seconds | > 2 minutes |
| Script Build  | < 30 seconds | 30-60 seconds  | > 1 minute  |
| P95 Duration  | < 4 minutes  | 4-6 minutes    | > 6 minutes |

## 🔍 How to Use

### Daily Monitoring

```bash
# Quick status check
nix develop
ci-status

# Detailed performance report
ci-perf
```

### Weekly Analysis

```bash
# Generate comprehensive report
./scripts/ci-perf-report.sh 7   # Last 7 days
./scripts/ci-perf-report.sh 30  # Last 30 days
```

### Investigating Performance Issues

1. **Check recent runs**: `ci-status`
2. **Analyze trends**: `ci-perf`
3. **Look for outliers**: Check runs that exceed P95 times
4. **Examine logs**: Visit slow run URLs from the report

## 📈 What Gets Tracked

### Build Metrics

- Individual component build times (React, Script)
- Total CI duration from start to finish
- Cache hit/miss performance indicators
- Step-by-step timing breakdowns

### Statistical Analysis

- **Average duration** over time periods
- **Median duration** (less affected by outliers)
- **P95 duration** (95th percentile - catches most slow runs)
- **Min/Max range** for variability analysis
- **Trend analysis** (getting faster/slower)

### Performance Alerts

- 🔴 **Critical**: > 5 minutes total CI time
- 🟡 **Warning**: 3-5 minutes total CI time
- ⚡ **Outlier Detection**: Runs significantly slower than average
- 📊 **Regression Detection**: Recent runs slower than historical average

## 🚨 Automated Alerts

### GitHub Actions Integration

- **Step Summary**: Performance table in every CI run
- **Warnings**: Automatic warnings for slow builds
- **Status Checks**: Fail CI if performance degrades severely

### Performance Monitor Workflow

- **Daily Reports**: Automated performance summaries
- **Regression Detection**: Alerts when average time increases
- **Historical Tracking**: Performance badge updates

## 💡 Optimization Strategies

### When CI Times Increase

1. **Check Cache Performance**
   - Verify Cachix hit rates
   - Look for cache invalidation patterns
   - Review cache key strategies

2. **Analyze Build Complexity**
   - Check if new dependencies were added
   - Review source file changes that affect builds
   - Verify Nix expression efficiency

3. **Infrastructure Issues**
   - GitHub Actions runner performance
   - Network latency to caches
   - Concurrent job scheduling

### Performance Best Practices

- **Keep dependencies minimal**: Only add what's needed
- **Optimize Nix expressions**: Use efficient source filtering
- **Cache aggressively**: Pre-build common dependencies
- **Parallel builds**: Where possible without resource conflicts
- **Monitor trends**: Catch regressions early

## 📋 Performance Checklist

Before merging PRs, consider:

- [ ] Did CI time increase significantly?
- [ ] Are new dependencies absolutely necessary?
- [ ] Can new build steps be optimized or cached?
- [ ] Does the change affect source filtering?
- [ ] Are there more efficient alternatives?

## 🔧 Troubleshooting Performance Issues

### Common Causes of Slow CI

1. **Cache Misses**: New dependencies or changed hashes
2. **Source Filtering**: Including unnecessary files in builds
3. **Network Issues**: Slow downloads from external sources
4. **Resource Contention**: Too many parallel operations
5. **Inefficient Scripts**: Slow bash commands or unnecessary work

### Debugging Steps

1. **Compare with baseline**: Use performance reports to identify when slowdown started
2. **Examine specific runs**: Look at GitHub Actions logs for slow steps
3. **Test locally**: Use `nix build --dry-run` to see what would be built
4. **Profile Nix**: Use `nix build --profile` for detailed timing
5. **Check cache status**: Verify Cachix configuration and hit rates

## 📊 Sample Performance Report

```
## 📊 CI Performance Summary

| Metric | Value | Status |
|--------|-------|--------|
| Average | 142s | ✅ |
| Median | 138s | ✅ |
| P95 | 189s | ✅ |
| Min | 98s | ✅ |
| Max | 245s | ⏰ |
| Total Runs | 23 | - |

## 📈 Performance Trend
✅ **Stable Performance**: No significant change in CI times

## 🕒 Recent Runs
| Date | Duration | Branch | Commit | Status |
|------|----------|--------|--------|--------|
| 2025-08-18 | 142s | main | fix: implement working React state... | ✅ Fast |
| 2025-08-18 | 138s | main | fix: use relative paths for GitHub... | ✅ Fast |
```

This monitoring system helps maintain fast, reliable CI while providing early warning of performance regressions!
