#!/bin/bash
# GitHub PR Review Automation Script
# Request ID: 1762434560861
# Purpose: Automate PR review workflow for Solita Denmark team

set -euo pipefail

# Configuration (use placeholders for now as per instructions)
GITHUB_TOKEN="${GITHUB_TOKEN:-REPLACE_WITH_YOUR_GITHUB_PAT}"
GITHUB_ORG="${GITHUB_ORG:-sundgaard-solita}"
GITHUB_REPO="${GITHUB_REPO:-REPLACE_WITH_REPO_NAME}"
PR_NUMBER="${PR_NUMBER:-REPLACE_WITH_ACTUAL_PR_NUMBER}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "================================================"
echo "GitHub PR Review Automation"
echo "Request ID: 1762434560861"
echo "================================================"
echo ""

# Function to check if PR exists and get details
check_pr() {
    echo -e "${YELLOW}Checking PR #${PR_NUMBER}...${NC}"
    
    if [ "$GITHUB_TOKEN" = "REPLACE_WITH_YOUR_GITHUB_PAT" ]; then
        echo -e "${RED}⚠️  GITHUB_TOKEN not configured. Set it as an environment variable.${NC}"
        echo "Example: export GITHUB_TOKEN='your_personal_access_token'"
        return 1
    fi
    
    HTTP_STATUS=$(curl -s -w "%{http_code}" -o pr_response.json \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/pulls/$PR_NUMBER")
    
    if [ "$HTTP_STATUS" != "200" ]; then
        echo -e "${RED}❌ Failed to fetch PR (HTTP $HTTP_STATUS)${NC}"
        cat pr_response.json 2>/dev/null || echo "No response data"
        return 1
    fi
    
    PR_DATA=$(cat pr_response.json)
    
    PR_TITLE=$(echo "$PR_DATA" | jq -r '.title')
    PR_STATE=$(echo "$PR_DATA" | jq -r '.state')
    PR_URL=$(echo "$PR_DATA" | jq -r '.html_url')
    
    if [ "$PR_TITLE" = "null" ]; then
        echo -e "${RED}❌ PR not found or access denied${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ PR Found:${NC}"
    echo "   Title: $PR_TITLE"
    echo "   State: $PR_STATE"
    echo "   URL: $PR_URL"
    echo ""
}

# Function to get PR reviews
get_reviews() {
    echo -e "${YELLOW}Fetching PR reviews...${NC}"
    
    REVIEWS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/pulls/$PR_NUMBER/reviews")
    
    REVIEW_COUNT=$(echo "$REVIEWS" | jq '. | length')
    
    echo -e "${GREEN}Reviews: $REVIEW_COUNT${NC}"
    echo "$REVIEWS" | jq -r '.[] | "   - \(.user.login): \(.state)"'
    echo ""
}

# Function to get PR checks
get_checks() {
    echo -e "${YELLOW}Fetching PR checks status...${NC}"
    
    # Get the head SHA from PR
    HEAD_SHA=$(echo "$PR_DATA" | jq -r '.head.sha')
    
    CHECKS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/commits/$HEAD_SHA/check-runs")
    
    CHECK_COUNT=$(echo "$CHECKS" | jq '.total_count')
    
    echo -e "${GREEN}Check runs: $CHECK_COUNT${NC}"
    echo "$CHECKS" | jq -r '.check_runs[] | "   - \(.name): \(.conclusion // .status)"'
    echo ""
}

# Function to notify teams about PR status
notify_teams() {
    local message=$1
    local webhook_url="${TEAMS_WEBHOOK_URL:-TEAMS_WEBHOOK_PLACEHOLDER}"
    
    if [ "$webhook_url" = "TEAMS_WEBHOOK_PLACEHOLDER" ]; then
        echo -e "${YELLOW}⚠️  TEAMS_WEBHOOK_URL not configured. Skipping Teams notification.${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Sending Teams notification...${NC}"
    
    # Properly escape message for JSON using jq
    local payload=$(jq -n --arg text "$message" '{text: $text}')
    
    HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$webhook_url")
    
    if [[ "$HTTP_STATUS" =~ ^2 ]]; then
        echo -e "${GREEN}✅ Teams notification sent (HTTP $HTTP_STATUS)${NC}"
    else
        echo -e "${RED}⚠️  Teams notification failed (HTTP $HTTP_STATUS)${NC}"
    fi
}

# Main execution
main() {
    echo "Starting PR review process..."
    echo ""
    
    # Check if required variables are set
    if [ "$GITHUB_TOKEN" = "REPLACE_WITH_YOUR_GITHUB_PAT" ]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  Configuration Required${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "This script requires the following environment variables:"
        echo ""
        echo "  export GITHUB_TOKEN='your_github_personal_access_token'"
        echo "  export GITHUB_ORG='sundgaard-solita'"
        echo "  export GITHUB_REPO='your_repository_name'"
        echo "  export PR_NUMBER='123'"
        echo "  export TEAMS_WEBHOOK_URL='https://...webhook.url' (optional)"
        echo ""
        echo "Then run: bash github-pr-operations.sh"
        echo ""
        return 1
    fi
    
    # Execute workflow
    check_pr || return 1
    get_reviews
    get_checks
    
    # Send notification
    notify_teams "🔍 PR #${PR_NUMBER} review initiated: $PR_URL"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ PR Review Process Completed${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Run main function
main
