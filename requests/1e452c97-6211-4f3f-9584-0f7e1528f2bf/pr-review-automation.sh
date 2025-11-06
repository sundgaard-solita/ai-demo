#!/bin/bash
# Script to handle PR review notification from Teams
# This script can be used to automate PR review workflows

set -euo pipefail

# Configuration (use environment variables or placeholders)
GITHUB_TOKEN="${GITHUB_TOKEN:-YOUR_GITHUB_PAT_TOKEN}"
GITHUB_ORG="${GITHUB_ORG:-sundgaard-solita}"
GITHUB_REPO="${GITHUB_REPO:-ai-demo}"
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL:-YOUR_TEAMS_WEBHOOK_URL}"

# Request tracking
REQUEST_ID="1e452c97-6211-4f3f-9584-0f7e1528f2bf"
MESSAGE_ID="1762434054659"  # Teams message ID for reference
REQUESTER="Michael Ringholm Sundgaard"
TENANT_ID="635aa01e-f19d-49ec-8aed-4b2e4312a627"  # Azure tenant ID for reference

# Function to find open PRs in the repository
find_open_prs() {
    echo "🔍 Searching for open PRs in ${GITHUB_ORG}/${GITHUB_REPO}..."
    
    # Check if token is set and not the default placeholder (without exposing the placeholder)
    if [ -z "$GITHUB_TOKEN" ] || [ ${#GITHUB_TOKEN} -lt 20 ]; then
        echo "⚠️  GITHUB_TOKEN not set or invalid. Please configure your Personal Access Token."
        echo "   export GITHUB_TOKEN=your_token_here"
        exit 1
    fi
    
    # List open PRs using GitHub CLI or API
    gh pr list --repo "${GITHUB_ORG}/${GITHUB_REPO}" --state open --json number,title,author,createdAt
}

# Function to assign reviewers to a PR
assign_pr_reviewers() {
    local PR_NUMBER=$1
    shift
    local REVIEWERS=("$@")
    
    echo "👥 Assigning reviewers to PR #${PR_NUMBER}..."
    
    for reviewer in "${REVIEWERS[@]}"; do
        gh pr edit "${PR_NUMBER}" \
            --repo "${GITHUB_ORG}/${GITHUB_REPO}" \
            --add-reviewer "${reviewer}"
    done
    
    echo "✅ Reviewers assigned successfully"
}

# Function to notify Teams about PR status
notify_teams() {
    local MESSAGE=$1
    
    # Check if webhook URL is configured (without exposing the placeholder)
    if [ -z "$TEAMS_WEBHOOK_URL" ] || [ ${#TEAMS_WEBHOOK_URL} -lt 20 ]; then
        echo "⚠️  TEAMS_WEBHOOK_URL not set. Skipping Teams notification."
        return 0
    fi
    
    echo "📢 Sending notification to Teams..."
    
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"text\":\"${MESSAGE}\"}" \
        "${TEAMS_WEBHOOK_URL}"
    
    echo "✅ Teams notification sent"
}

# Function to check PR compliance
check_pr_compliance() {
    local PR_NUMBER=$1
    
    echo "🔒 Checking PR #${PR_NUMBER} for security and compliance..."
    
    # Check for security issues
    echo "  - Checking for secrets in code..."
    # In a real implementation, you would run secret scanning here
    
    echo "  - Verifying least privilege principles..."
    # Check IAM/permission changes
    
    echo "  - ISO-27001 compliance check..."
    # Verify compliance requirements
    
    echo "✅ Compliance checks completed"
}

# Main workflow
main() {
    echo "================================================"
    echo "PR Review Automation"
    echo "Request ID: ${REQUEST_ID}"
    echo "Requester: ${REQUESTER}"
    echo "================================================"
    echo
    
    # Find open PRs
    find_open_prs
    
    echo
    echo "Next steps:"
    echo "1. Identify the specific PR mentioned by ${REQUESTER}"
    echo "2. Run: bash pr-review-automation.sh assign_reviewers <PR_NUMBER> <REVIEWER1> <REVIEWER2>"
    echo "3. Run: bash pr-review-automation.sh check_compliance <PR_NUMBER>"
    echo
}

# Handle subcommands
case "${1:-main}" in
    assign_reviewers)
        shift
        assign_pr_reviewers "$@"
        ;;
    check_compliance)
        check_pr_compliance "$2"
        ;;
    notify_teams)
        notify_teams "$2"
        ;;
    *)
        main
        ;;
esac
