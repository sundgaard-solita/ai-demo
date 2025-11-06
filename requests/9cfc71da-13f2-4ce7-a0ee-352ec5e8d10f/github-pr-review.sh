#!/usr/bin/env bash
# GitHub PR Review Script
# This script can be used to interact with GitHub PRs when a notification is received from Teams
#
# Prerequisites:
# - GitHub CLI (gh) installed
# - Authenticated with GitHub (gh auth login)
# - Appropriate permissions to access the repository
#
# Usage:
#   ./github-pr-review.sh [repository-owner/repository-name] [pr-number]
#
# Note: This is a template script. Actual PR number and repository need to be provided.

set -e

# Configuration (use placeholders that can be updated later)
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN}}"
REPOSITORY="${1:-PLACEHOLDER_REPO}"
PR_NUMBER="${2:-PLACEHOLDER_PR_NUMBER}"

# Validate inputs
if [[ "$REPOSITORY" == "PLACEHOLDER_REPO" ]] || [[ "$PR_NUMBER" == "PLACEHOLDER_PR_NUMBER" ]]; then
    echo "⚠️  Usage: $0 <repository> <pr-number>"
    echo "   Example: $0 sundgaard-solita/ai-demo 123"
    echo ""
    echo "   This script will:"
    echo "   1. Fetch PR details"
    echo "   2. Display PR status"
    echo "   3. Show recent commits"
    echo "   4. Display check runs status"
    exit 1
fi

echo "🔍 Fetching PR #${PR_NUMBER} from ${REPOSITORY}..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   https://cli.github.com/"
    exit 1
fi

# Fetch PR details
echo ""
echo "📋 PR Details:"
gh pr view "$PR_NUMBER" --repo "$REPOSITORY"

echo ""
echo "✅ PR Checks Status:"
gh pr checks "$PR_NUMBER" --repo "$REPOSITORY"

echo ""
echo "📝 Recent Commits:"
gh pr view "$PR_NUMBER" --repo "$REPOSITORY" --json commits --jq '.commits[-5:] | .[] | "- \(.commit.message) by \(.author.login)"'

echo ""
echo "💬 To review the PR in your browser, run:"
echo "   gh pr view $PR_NUMBER --repo $REPOSITORY --web"

echo ""
echo "✅ Script completed successfully!"
