#!/bin/bash
# GitHub PR Review Automation Script
# Purpose: Automate PR review process for request 1762434200107

set -e

# Configuration
GITHUB_TOKEN="${PAT_TOKEN:-$GITHUB_TOKEN}"
GITHUB_REPO="${GITHUB_REPOSITORY:-sundgaard-solita/ai-demo}"
REQUEST_ID="1762434200107"

# Validate required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN or PAT_TOKEN is required"
    exit 1
fi

echo "🔍 Fetching latest pull requests for $GITHUB_REPO..."

# Get the latest open PRs
LATEST_PR=$(gh pr list --repo "$GITHUB_REPO" --state open --limit 1 --json number,title,author,url)

if [ -z "$LATEST_PR" ] || [ "$LATEST_PR" = "[]" ]; then
    echo "⚠️  No open pull requests found"
    exit 0
fi

PR_NUMBER=$(echo "$LATEST_PR" | jq -r '.[0].number')
PR_TITLE=$(echo "$LATEST_PR" | jq -r '.[0].title')
PR_AUTHOR=$(echo "$LATEST_PR" | jq -r '.[0].author.login')
PR_URL=$(echo "$LATEST_PR" | jq -r '.[0].url')

echo "📋 Found PR #$PR_NUMBER: $PR_TITLE"
echo "👤 Author: $PR_AUTHOR"
echo "🔗 URL: $PR_URL"

# Run automated checks
echo ""
echo "🧪 Running automated checks..."

# Check 1: Verify PR has description
PR_BODY=$(gh pr view "$PR_NUMBER" --repo "$GITHUB_REPO" --json body -q .body)
if [ -z "$PR_BODY" ] || [ "$PR_BODY" = "null" ]; then
    echo "⚠️  PR has no description"
    gh pr comment "$PR_NUMBER" --repo "$GITHUB_REPO" --body "⚠️ Please add a description to this PR explaining the changes."
fi

# Check 2: Verify CI checks are passing
echo "Checking CI status..."
gh pr checks "$PR_NUMBER" --repo "$GITHUB_REPO" || echo "⚠️  Some checks are failing"

# Check 3: Review PR files
echo "Reviewing changed files..."
gh pr diff "$PR_NUMBER" --repo "$GITHUB_REPO" > "/tmp/pr-${PR_NUMBER}-diff.txt"
FILE_COUNT=$(gh pr view "$PR_NUMBER" --repo "$GITHUB_REPO" --json files -q '.files | length')
echo "📁 Files changed: $FILE_COUNT"

# Add review comment
echo ""
echo "✅ Automated review completed"
echo ""
echo "Summary:"
echo "- PR Number: #$PR_NUMBER"
echo "- Title: $PR_TITLE"
echo "- Author: $PR_AUTHOR"
echo "- Files Changed: $FILE_COUNT"
echo ""
echo "Next steps:"
echo "1. Review the changes manually at: $PR_URL"
echo "2. Approve the PR if everything looks good"
echo "3. Merge when ready"

# Save review results
cat > "/tmp/review-results-${REQUEST_ID}.json" <<EOF
{
  "request_id": "$REQUEST_ID",
  "pr_number": $PR_NUMBER,
  "pr_title": "$PR_TITLE",
  "pr_author": "$PR_AUTHOR",
  "pr_url": "$PR_URL",
  "files_changed": $FILE_COUNT,
  "review_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "automated_review_completed"
}
EOF

echo ""
echo "📝 Review results saved to /tmp/review-results-${REQUEST_ID}.json"
