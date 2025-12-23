#!/bin/bash
#
# GitHub Team Management Script
# Purpose: Add user to RIT2 GitHub Team
# Request ID: 1762259868977
# Date: 2025-11-04
#

set -euo pipefail

# Configuration - UPDATE THESE VALUES
ORGANIZATION="${GITHUB_ORG:-sundgaard-solita}"
TEAM_SLUG="${TEAM_SLUG:-rit2}"
USERNAME="${GITHUB_USERNAME:-sundgaard}"
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
ROLE="${ROLE:-member}"  # Options: member, maintainer
PAT_TOKEN="${GITHUB_PAT:-PLACEHOLDER_PAT_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "GitHub Team Management Script"
echo "Request ID: 1762259868977"
echo "================================================"
echo ""

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI is not installed. Please install it first."
    echo ""
    echo "Installation instructions:"
    echo "  macOS:   brew install gh"
    echo "  Ubuntu:  sudo apt install gh"
    echo "  Windows: winget install GitHub.cli"
    exit 1
fi

print_info "GitHub CLI is installed"

# Check if authenticated
if ! gh auth status &> /dev/null; then
    print_warning "Not authenticated to GitHub. Attempting login..."
    
    if [ "$PAT_TOKEN" != "PLACEHOLDER_PAT_TOKEN" ]; then
        echo "$PAT_TOKEN" | gh auth login --with-token
    else
        print_error "PAT token not configured. Please set GITHUB_PAT environment variable."
        echo ""
        echo "To generate a PAT token:"
        echo "1. Go to: https://github.com/settings/tokens"
        echo "2. Create a new token (classic) with 'admin:org' scope"
        echo "3. Export it: export GITHUB_PAT='your-token-here'"
        echo ""
        echo "Alternatively, run: gh auth login"
        exit 1
    fi
fi

print_info "Authenticated to GitHub"

# Verify organization access
print_info "Verifying access to organization: $ORGANIZATION"
if ! gh api "/orgs/$ORGANIZATION" &> /dev/null; then
    print_error "Cannot access organization '$ORGANIZATION'"
    echo ""
    echo "Available organizations:"
    gh api user/orgs --jq '.[].login'
    exit 1
fi

print_info "Organization found: $ORGANIZATION"

# Verify team exists
print_info "Verifying team: $TEAM_SLUG"
TEAM_ID=$(gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG" --jq '.id' 2>/dev/null || echo "")

if [ -z "$TEAM_ID" ]; then
    print_error "Team '$TEAM_SLUG' not found in organization '$ORGANIZATION'"
    echo ""
    echo "Available teams:"
    gh api "/orgs/$ORGANIZATION/teams" --jq '.[] | "\(.slug) - \(.name)"'
    exit 1
fi

print_info "Team found: $TEAM_SLUG (ID: $TEAM_ID)"

# Get team details
TEAM_NAME=$(gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG" --jq '.name')
TEAM_DESCRIPTION=$(gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG" --jq '.description // "No description"')

echo ""
echo "Team Details:"
echo "  Name: $TEAM_NAME"
echo "  Slug: $TEAM_SLUG"
echo "  Description: $TEAM_DESCRIPTION"
echo ""

# Check if user exists
print_info "Verifying user: $USERNAME"
if ! gh api "/users/$USERNAME" &> /dev/null; then
    print_error "User '$USERNAME' not found on GitHub"
    exit 1
fi

USER_FULL_NAME=$(gh api "/users/$USERNAME" --jq '.name // .login')
print_info "User found: $USER_FULL_NAME (@$USERNAME)"

# Check if user is already a team member
print_info "Checking team membership..."
MEMBERSHIP_STATUS=$(gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG/memberships/$USERNAME" --jq '.state' 2>/dev/null || echo "not_found")

if [ "$MEMBERSHIP_STATUS" = "active" ]; then
    CURRENT_ROLE=$(gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG/memberships/$USERNAME" --jq '.role')
    print_warning "User is already a member of team '$TEAM_SLUG' with role '$CURRENT_ROLE'"
    echo ""
    
    # Show team members
    print_info "Current team members:"
    gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG/members" --jq '.[] | "\(.login) - \(.name // "N/A")"'
    exit 0
fi

# Add user to team
print_info "Adding user '$USERNAME' to team '$TEAM_SLUG' with role '$ROLE'..."

if gh api \
    --method PUT \
    "/orgs/$ORGANIZATION/teams/$TEAM_SLUG/memberships/$USERNAME" \
    -f role="$ROLE" &> /dev/null; then
    
    print_info "✅ Successfully added user to team!"
    echo ""
    echo "Summary:"
    echo "  User: $USER_DISPLAY_NAME (@$USERNAME)"
    echo "  Organization: $ORGANIZATION"
    echo "  Team: $TEAM_NAME ($TEAM_SLUG)"
    echo "  Role: $ROLE"
    echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    
    # Show updated team members
    print_info "Current team members:"
    gh api "/orgs/$ORGANIZATION/teams/$TEAM_SLUG/members" --jq '.[] | "\(.login) - \(.name // "N/A")"'
    
    # Log the operation (ISO-27001 compliance)
    LOG_FILE="./audit-log.txt"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Added user '$USERNAME' to GitHub team '$TEAM_SLUG' in organization '$ORGANIZATION' with role '$ROLE'" >> "$LOG_FILE"
    print_info "Operation logged to: $LOG_FILE"
    
else
    print_error "Failed to add user to team"
    exit 1
fi

echo ""
echo "================================================"
echo "Operation completed successfully"
echo "================================================"
echo ""
echo "Note: User may need to accept the invitation if the organization requires it."
