#!/bin/bash
# CI Performance Report Generator
# Usage: ./scripts/ci-perf-report.sh [days]

set -e

DAYS=${1:-30}  # Default to 30 days
REPO_NAME=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "🔍 Generating CI Performance Report for last $DAYS days..."
echo "Repository: $REPO_NAME"
echo ""

# Get workflow runs data
echo "Fetching workflow data..."
gh run list --workflow=ci.yml --limit=100 --json number,conclusion,createdAt,updatedAt,displayTitle,headBranch > /tmp/runs.json

# Generate performance report
node -e "
const fs = require('fs');
const runs = JSON.parse(fs.readFileSync('/tmp/runs.json', 'utf8'));

// Filter runs from the last N days
const cutoffDate = new Date();
cutoffDate.setDate(cutoffDate.getDate() - $DAYS);

const recentRuns = runs
  .filter(run => new Date(run.createdAt) > cutoffDate)
  .filter(run => run.conclusion === 'success')
  .map(run => ({
    id: run.number,
    title: run.displayTitle,
    branch: run.headBranch,
    duration: Math.round((new Date(run.updatedAt) - new Date(run.createdAt)) / 1000),
    date: new Date(run.createdAt).toISOString().split('T')[0],
    timestamp: new Date(run.createdAt).getTime()
  }))
  .sort((a, b) => b.timestamp - a.timestamp);

if (recentRuns.length === 0) {
  console.log('❌ No successful CI runs found in the last $DAYS days');
  process.exit(1);
}

// Calculate statistics
const durations = recentRuns.map(r => r.duration);
const avgDuration = Math.round(durations.reduce((sum, d) => sum + d, 0) / durations.length);
const medianDuration = durations.sort((a, b) => a - b)[Math.floor(durations.length / 2)];
const minDuration = Math.min(...durations);
const maxDuration = Math.max(...durations);
const p95Duration = durations.sort((a, b) => a - b)[Math.floor(durations.length * 0.95)];

console.log('## 📊 CI Performance Summary');
console.log('');
console.log('| Metric | Value | Status |');
console.log('|--------|-------|--------|');
console.log(\`| Average | \${avgDuration}s | \${avgDuration > 300 ? '⚠️' : avgDuration > 180 ? '⏰' : '✅'} |\`);
console.log(\`| Median | \${medianDuration}s | \${medianDuration > 300 ? '⚠️' : medianDuration > 180 ? '⏰' : '✅'} |\`);
console.log(\`| P95 | \${p95Duration}s | \${p95Duration > 400 ? '⚠️' : p95Duration > 250 ? '⏰' : '✅'} |\`);
console.log(\`| Min | \${minDuration}s | ✅ |\`);
console.log(\`| Max | \${maxDuration}s | \${maxDuration > 600 ? '⚠️' : maxDuration > 400 ? '⏰' : '✅'} |\`);
console.log(\`| Total Runs | \${recentRuns.length} | - |\`);
console.log('');

// Performance trend analysis
console.log('## 📈 Performance Trend');
console.log('');
const recentAvg = recentRuns.slice(0, 5).reduce((sum, r) => sum + r.duration, 0) / 5;
const olderAvg = recentRuns.slice(-5).reduce((sum, r) => sum + r.duration, 0) / 5;
const trend = recentAvg - olderAvg;

if (Math.abs(trend) < 10) {
  console.log('✅ **Stable Performance**: No significant change in CI times');
} else if (trend > 0) {
  console.log(\`⚠️ **Performance Regression**: CI times increased by ~\${Math.round(trend)}s\`);
} else {
  console.log(\`🚀 **Performance Improvement**: CI times decreased by ~\${Math.round(Math.abs(trend))}s\`);
}
console.log('');

// Recent runs table
console.log('## 🕒 Recent Runs');
console.log('');
console.log('| Date | Duration | Branch | Commit | Status |');
console.log('|------|----------|--------|--------|--------|');
recentRuns.slice(0, 10).forEach(run => {
  const status = run.duration > 300 ? '⚠️ Slow' : run.duration > 180 ? '⏰ OK' : '✅ Fast';
  const shortTitle = run.title.length > 40 ? run.title.substring(0, 40) + '...' : run.title;
  console.log(\`| \${run.date} | \${run.duration}s | \${run.branch} | \${shortTitle} | \${status} |\`);
});

// Outliers analysis
const outliers = recentRuns.filter(run => run.duration > avgDuration + (2 * Math.sqrt(durations.reduce((sum, d) => sum + Math.pow(d - avgDuration, 2), 0) / durations.length)));
if (outliers.length > 0) {
  console.log('');
  console.log('## ⚠️ Performance Outliers');
  console.log('');
  console.log('Runs that took significantly longer than average:');
  console.log('');
  outliers.forEach(run => {
    console.log(\`- [\${run.id}](https://github.com/$REPO_NAME/actions/runs/\${run.id}): \${run.duration}s (\${run.date}) - \${run.title}\`);
  });
}

// Performance recommendations
console.log('');
console.log('## 💡 Recommendations');
console.log('');
if (avgDuration > 300) {
  console.log('- 🔴 **Critical**: Average CI time exceeds 5 minutes');
  console.log('- Consider parallelizing builds or reducing test scope');
} else if (avgDuration > 180) {
  console.log('- 🟡 **Warning**: CI times are getting long');
  console.log('- Monitor for further regression');
} else {
  console.log('- ✅ **Good**: CI times are within acceptable range');
}

if (maxDuration > avgDuration * 2) {
  console.log('- 📊 **High Variability**: Some runs take much longer than others');
  console.log('- Investigate inconsistent performance');
}

console.log('- 📈 Track trends with: \`./scripts/ci-perf-report.sh\`');
console.log('- 🔍 Investigate slow runs in GitHub Actions logs');
console.log('- ⚡ Consider caching improvements if cache hit rate is low');
"

echo ""
echo "📊 Report generated! Use this data to:"
echo "   • Track performance over time"  
echo "   • Identify performance regressions"
echo "   • Plan optimization efforts"
echo ""
echo "💡 Pro tip: Run weekly to catch trends early!"