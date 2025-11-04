#!/bin/bash
# GitHub - Add User to Team
# Request ID: 1762261162456
# Description: Add Michael Ringholm Sundgaard (MRS) to RIT5 team

# Configuration
GITHUB_USERNAME="michael-sundgaard"  # Placeholder - update with actual GitHub username
TEAM_SLUG="rit5"  # Team slug (lowercase, hyphenated version of team name)
ORG_NAME="solita"  # Placeholder - update with actual GitHub organization
ROLE="member"  # Can be "member" or "maintainer"
REQUEST_ID="1762261162456"

# Prerequisites:
# - GitHub CLI installed: https://cli.github.com/
# - Authenticated: gh auth login
# - Permissions to manage team membership in the organization

echo "========================================"
echo "GitHub Team Membership Update"
echo "========================================"
echo ""
echo "Request ID: $REQUEST_ID"
echo "User: Michael Ringholm Sundgaard"
echo "GitHub Username: $GITHUB_USERNAME"
echo "Target Team: $TEAM_SLUG"
echo "Organization: $ORG_NAME"
echo "Role: $ROLE"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI is not installed"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "ERROR: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

# Verify the team exists
echo "Checking if team exists..."
TEAM_CHECK=$(gh api "/orgs/$ORG_NAME/teams/$TEAM_SLUG" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "ERROR: Team '$TEAM_SLUG' not found in organization '$ORG_NAME'"
    echo "Please verify the team slug and organization name"
    exit 1
fi

echo "Found team: $TEAM_SLUG"

# Check if user is already a member
echo "Checking current team membership..."
EXISTING_MEMBER=$(gh api "/orgs/$ORG_NAME/teams/$TEAM_SLUG/memberships/$GITHUB_USERNAME" 2>/dev/null)

if [ $? -eq 0 ]; then
    CURRENT_ROLE=$(echo "$EXISTING_MEMBER" | jq -r '.role')
    echo "WARNING: User is already a member of team '$TEAM_SLUG' with role: $CURRENT_ROLE"
    exit 0
fi

# Add user to team
echo "Adding user to team..."
RESULT=$(gh api \
    --method PUT \
    "/orgs/$ORG_NAME/teams/$TEAM_SLUG/memberships/$GITHUB_USERNAME" \
    -f role="$ROLE" 2>&1)

if [ $? -eq 0 ]; then
    echo ""
    echo "SUCCESS: User successfully added to team '$TEAM_SLUG'"
    echo ""
    echo "Audit Information:"
    echo "- Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "- Request ID: $REQUEST_ID"
    echo "- User: $GITHUB_USERNAME"
    echo "- Team: $TEAM_SLUG"
    echo "- Organization: $ORG_NAME"
    echo "- Role: $ROLE"
    echo ""
    echo "The user will receive an invitation email if not already part of the organization."
else
    echo "ERROR: Failed to add user to team"
    echo "$RESULT"
    exit 1
fi
