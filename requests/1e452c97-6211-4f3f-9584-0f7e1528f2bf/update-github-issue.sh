#!/bin/bash
# GitHub Issue Update Script
# Updates the GitHub issue with processed content from Teams message

set -euo pipefail

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-YOUR_GITHUB_PAT_TOKEN}"
GITHUB_ORG="${GITHUB_ORG:-sundgaard-solita}"
GITHUB_REPO="${GITHUB_REPO:-ai-demo}"
ISSUE_NUMBER="${ISSUE_NUMBER:-}"

# Request tracking
REQUEST_ID="1e452c97-6211-4f3f-9584-0f7e1528f2bf"
REQUEST_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read the processed issue content
PROCESSED_CONTENT_FILE="${REQUEST_DIR}/processed-issue.md"

if [ ! -f "$PROCESSED_CONTENT_FILE" ]; then
    echo "❌ Processed content file not found: $PROCESSED_CONTENT_FILE"
    exit 1
fi

# Function to update GitHub issue
update_github_issue() {
    local ISSUE_NUM=$1
    
    echo "📝 Updating GitHub issue #${ISSUE_NUM}..."
    
    # Check if token is set and not the default placeholder (without exposing the placeholder)
    if [ -z "$GITHUB_TOKEN" ] || [ ${#GITHUB_TOKEN} -lt 20 ]; then
        echo "⚠️  GITHUB_TOKEN not set or invalid. Please configure your Personal Access Token."
        echo "   export GITHUB_TOKEN=your_token_here"
        echo ""
        echo "To update manually, use:"
        echo "   gh issue edit ${ISSUE_NUM} --title 'PR Ready for Review - Michael Ringholm Sundgaard' --body-file '${PROCESSED_CONTENT_FILE}'"
        exit 1
    fi
    
    # Extract title from processed content (first line after #)
    TITLE=$(grep -m 1 "^# " "$PROCESSED_CONTENT_FILE" | sed 's/^# //')
    
    # Read the full content
    BODY=$(cat "$PROCESSED_CONTENT_FILE")
    
    # Update the issue using GitHub API
    gh api --method PATCH \
        "repos/${GITHUB_ORG}/${GITHUB_REPO}/issues/${ISSUE_NUM}" \
        -f title="$TITLE" \
        -f body="$BODY" \
        -f state="open"
    
    echo "✅ Issue #${ISSUE_NUM} updated successfully"
    
    # Add a comment with tracking information
    COMMENT="🤖 **Automated Processing Complete**

This issue has been processed from a Teams message.

**Request ID:** \`${REQUEST_ID}\`
**Processed:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

All relevant documentation and automation scripts have been created in:
\`requests/${REQUEST_ID}/\`
"
    
    gh api --method POST \
        "repos/${GITHUB_ORG}/${GITHUB_REPO}/issues/${ISSUE_NUM}/comments" \
        -f body="$COMMENT"
    
    echo "✅ Tracking comment added to issue"
}

# Main function
main() {
    if [ -z "$ISSUE_NUMBER" ]; then
        echo "❌ ISSUE_NUMBER environment variable not set"
        echo ""
        echo "Usage:"
        echo "   export ISSUE_NUMBER=<issue_number>"
        echo "   export GITHUB_TOKEN=<your_pat_token>"
        echo "   bash update-github-issue.sh"
        echo ""
        echo "Or:"
        echo "   ISSUE_NUMBER=<issue_number> GITHUB_TOKEN=<token> bash update-github-issue.sh"
        exit 1
    fi
    
    update_github_issue "$ISSUE_NUMBER"
}

main
