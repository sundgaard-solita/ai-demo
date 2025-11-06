#!/bin/bash
# GitHub PR Review Script
# This script helps list and review pending pull requests

set -e

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-$GH_OAUTH_TEMP_LOGIN_SECRET}"
REPO="${GITHUB_REPOSITORY:-sundgaard-solita/ai-demo}"
REQUEST_ID="99f61942-2006-4948-9f8a-e105286de6b0"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}GitHub PR Review Helper${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Request ID: $REQUEST_ID"
echo "Repository: $REPO"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# List all open PRs
echo -e "${YELLOW}Listing open Pull Requests...${NC}"
echo ""
gh pr list --repo "$REPO" --state open --json number,title,author,createdAt,updatedAt \
    --template '{{range .}}PR #{{.number}}: {{.title}}
  Author: {{.author.login}}
  Created: {{.createdAt}}
  Updated: {{.updatedAt}}
  
{{end}}'

# Prompt for PR number to review
echo ""
read -p "Enter PR number to review (or press Enter to skip): " PR_NUMBER

if [ -z "$PR_NUMBER" ]; then
    echo "No PR number provided. Exiting."
    exit 0
fi

# Show PR details
echo ""
echo -e "${YELLOW}Fetching PR #$PR_NUMBER details...${NC}"
gh pr view "$PR_NUMBER" --repo "$REPO"

# Show PR diff summary
echo ""
echo -e "${YELLOW}PR Changes Summary:${NC}"
gh pr diff "$PR_NUMBER" --repo "$REPO" | head -100

# Check PR status
echo ""
echo -e "${YELLOW}PR Status Checks:${NC}"
gh pr checks "$PR_NUMBER" --repo "$REPO"

# Prompt for action
echo ""
echo -e "${GREEN}What would you like to do?${NC}"
echo "1. Approve PR"
echo "2. Request changes"
echo "3. Comment on PR"
echo "4. Merge PR"
echo "5. Exit"
read -p "Enter choice [1-5]: " CHOICE

case $CHOICE in
    1)
        read -p "Enter approval comment (optional): " COMMENT
        if [ -z "$COMMENT" ]; then
            gh pr review "$PR_NUMBER" --repo "$REPO" --approve
        else
            gh pr review "$PR_NUMBER" --repo "$REPO" --approve --body "$COMMENT"
        fi
        echo -e "${GREEN}PR approved!${NC}"
        ;;
    2)
        read -p "Enter reason for changes: " COMMENT
        gh pr review "$PR_NUMBER" --repo "$REPO" --request-changes --body "$COMMENT"
        echo -e "${YELLOW}Changes requested${NC}"
        ;;
    3)
        read -p "Enter comment: " COMMENT
        gh pr review "$PR_NUMBER" --repo "$REPO" --comment --body "$COMMENT"
        echo -e "${GREEN}Comment added${NC}"
        ;;
    4)
        read -p "Are you sure you want to merge? (y/n): " CONFIRM
        if [ "$CONFIRM" = "y" ]; then
            gh pr merge "$PR_NUMBER" --repo "$REPO" --merge
            echo -e "${GREEN}PR merged!${NC}"
        else
            echo "Merge cancelled"
        fi
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
