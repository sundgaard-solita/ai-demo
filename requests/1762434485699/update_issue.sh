#!/bin/bash
# Issue Update Script for Request 1762434485699
# This script demonstrates how to update the GitHub issue with processed information
# Requires: GH_TOKEN or GITHUB_TOKEN environment variable with appropriate permissions

set -e

ISSUE_NUMBER="${ISSUE_NUMBER:-}" # Set this to the actual issue number
REPO="${GITHUB_REPOSITORY:-sundgaard-solita/ai-demo}"
REQUEST_ID="1762434485699"

if [ -z "$ISSUE_NUMBER" ]; then
  echo "Error: ISSUE_NUMBER environment variable is required"
  echo "Usage: ISSUE_NUMBER=123 ./update_issue.sh"
  exit 1
fi

echo "Updating issue #${ISSUE_NUMBER} in ${REPO}..."

# Update issue title
NEW_TITLE="PR Ready in GitHub - Message from Michael Ringholm Sundgaard"

# Update issue body
NEW_BODY=$(cat <<'EOF'
## Message Summary
PR is ready in GitHub.

## Details
- **From**: Michael Ringholm Sundgaard
- **Date**: November 6, 2025 at 13:08 UTC
- **Original Message**: PR ligger klar i GitHub. (Danish: "PR is ready in GitHub")

## Action Items
- [ ] Review the PR mentioned in GitHub

---
*This issue was automatically created from a Microsoft Teams message (ID: 1762434485699)*
EOF
)

# Update the issue using GitHub CLI
gh issue edit "$ISSUE_NUMBER" \
  --repo "$REPO" \
  --title "$NEW_TITLE" \
  --body "$NEW_BODY"

echo "✅ Issue #${ISSUE_NUMBER} updated successfully"
echo "📁 Processed data saved in: requests/${REQUEST_ID}/"
