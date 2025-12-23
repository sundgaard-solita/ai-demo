#!/bin/bash
#
# GitHub Operations Script for Request 0f474577-a2f5-4e35-81f4-814512d51a58
#
# Purpose: Automate GitHub PR review operations
# Context: Solita Denmark IT - PR notification from Teams
#
# Security: ISO-27001 compliant, least privilege principle
#

set -e  # Exit on error
set -u  # Exit on undefined variable

# Configuration
REQUEST_ID="0f474577-a2f5-4e35-81f4-814512d51a58"
GITHUB_ORG="sundgaard-solita"  # Placeholder - adjust as needed
GITHUB_REPO="${GITHUB_REPO:-}"  # To be determined
PR_NUMBER="${PR_NUMBER:-}"      # To be determined
GITHUB_TOKEN="${GITHUB_TOKEN:-}"  # Set via environment or GitHub Actions

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    if [ -z "${GITHUB_TOKEN}" ]; then
        log_error "GITHUB_TOKEN is not set. Please set it as an environment variable."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warn "jq is not installed. Some features may be limited."
    fi
    
    log_info "Prerequisites validated."
}

# Get PR information
get_pr_info() {
    if [ -z "${GITHUB_REPO}" ] || [ -z "${PR_NUMBER}" ]; then
        log_error "GITHUB_REPO and PR_NUMBER must be set"
        log_info "Usage: GITHUB_REPO=repo-name PR_NUMBER=123 $0"
        exit 1
    fi
    
    log_info "Fetching PR #${PR_NUMBER} from ${GITHUB_ORG}/${GITHUB_REPO}..."
    
    gh pr view "${PR_NUMBER}" \
        --repo "${GITHUB_ORG}/${GITHUB_REPO}" \
        --json number,title,state,author,createdAt,updatedAt,mergeable,reviews \
        | jq .
}

# Check PR status
check_pr_status() {
    log_info "Checking PR status..."
    
    gh pr checks "${PR_NUMBER}" \
        --repo "${GITHUB_ORG}/${GITHUB_REPO}"
}

# Review PR (placeholder - actual review requires manual inspection)
review_pr() {
    log_info "To review PR #${PR_NUMBER}, use:"
    echo "  gh pr review ${PR_NUMBER} --repo ${GITHUB_ORG}/${GITHUB_REPO} --approve"
    echo "  gh pr review ${PR_NUMBER} --repo ${GITHUB_ORG}/${GITHUB_REPO} --request-changes --body 'Comments here'"
    echo "  gh pr review ${PR_NUMBER} --repo ${GITHUB_ORG}/${GITHUB_REPO} --comment --body 'Comments here'"
}

# Add comment to PR
add_pr_comment() {
    local comment="$1"
    log_info "Adding comment to PR #${PR_NUMBER}..."
    
    gh pr comment "${PR_NUMBER}" \
        --repo "${GITHUB_ORG}/${GITHUB_REPO}" \
        --body "${comment}"
}

# Main execution
main() {
    log_info "GitHub Operations Script - Request ID: ${REQUEST_ID}"
    log_info "======================================================="
    
    # Validate prerequisites
    validate_prerequisites
    
    # Check if repo and PR are specified
    if [ -z "${GITHUB_REPO}" ] || [ -z "${PR_NUMBER}" ]; then
        log_warn "Repository and PR number not specified."
        log_info "This script requires GITHUB_REPO and PR_NUMBER to be set."
        log_info ""
        log_info "Example usage:"
        log_info "  GITHUB_REPO=ai-demo PR_NUMBER=42 $0"
        log_info ""
        log_info "Once you have the PR details from Michael Ringholm Sundgaard,"
        log_info "you can use this script to automate PR operations."
        exit 0
    fi
    
    # Get PR information
    get_pr_info
    
    # Check PR status
    check_pr_status
    
    # Show review instructions
    review_pr
    
    log_info "======================================================="
    log_info "Script completed successfully."
}

# Run main function
main "$@"
