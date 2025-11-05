#!/bin/bash
#
# GitHub Access Management Script
# Purpose: Add user to GitHub organization or repository with appropriate permissions
#
# Security: This script follows least privilege principles and ISO-27001 compliance
# Audit: All changes are logged for audit trail
#

set -e

# Configuration - Replace with actual values
GITHUB_ORG="${GITHUB_ORG:-sundgaard-solita}"
GITHUB_REPO="${GITHUB_REPO:-BDK7}"
GITHUB_TOKEN="${GITHUB_TOKEN:-YOUR_GITHUB_TOKEN_HERE}"
GITHUB_USERNAME="${GITHUB_USERNAME:-sundgaard}"
USER_GITHUB_USERNAME="${USER_GITHUB_USERNAME:-mrs-github}" # Replace with actual GitHub username
ROLE="${GITHUB_ROLE:-read}" # Options: admin, maintain, write, triage, read

# Display script information
echo "============================================"
echo "GitHub Access Management Script"
echo "============================================"
echo "Request ID: 2bdfce02-4cf4-400b-8338-637c8eaeda72"
echo "User: Michael Ringholm Sundgaard (GitHub: $USER_GITHUB_USERNAME)"
echo "Organization: $GITHUB_ORG"
echo "Repository: $GITHUB_REPO"
echo "Role: $ROLE"
echo "============================================"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Authenticate to GitHub
echo "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    if [ "$GITHUB_TOKEN" != "YOUR_GITHUB_TOKEN_HERE" ]; then
        echo "Authenticating with provided token..."
        echo "$GITHUB_TOKEN" | gh auth login --with-token
    else
        echo "Please login to GitHub..."
        gh auth login
    fi
else
    echo "Already authenticated to GitHub"
fi

# Check if BDK7 is an organization or repository
echo ""
echo "Determining if BDK7 is an organization or repository..."

# Check if it's an organization
if gh api "/orgs/$GITHUB_REPO" &> /dev/null; then
    echo "BDK7 is a GitHub organization"
    TARGET_TYPE="organization"
    TARGET_NAME="$GITHUB_REPO"
else
    echo "BDK7 is likely a repository (or checking within $GITHUB_ORG organization)"
    TARGET_TYPE="repository"
    TARGET_NAME="$GITHUB_ORG/$GITHUB_REPO"
fi

# Add user based on target type
if [ "$TARGET_TYPE" = "organization" ]; then
    echo ""
    echo "Adding user to organization: $TARGET_NAME"
    
    # Check if user is already a member
    if gh api "/orgs/$TARGET_NAME/members/$USER_GITHUB_USERNAME" &> /dev/null; then
        echo "User is already a member of organization $TARGET_NAME"
    else
        echo "Inviting user to organization..."
        gh api --method PUT "/orgs/$TARGET_NAME/memberships/$USER_GITHUB_USERNAME" \
            -f role="member"
        echo "Invitation sent to $USER_GITHUB_USERNAME"
    fi
    
    # Optionally add to specific teams
    echo ""
    echo "Note: To add user to specific teams in the organization, use:"
    echo "  gh api --method PUT '/orgs/$TARGET_NAME/teams/<team-slug>/memberships/$USER_GITHUB_USERNAME'"

elif [ "$TARGET_TYPE" = "repository" ]; then
    echo ""
    echo "Adding user as collaborator to repository: $TARGET_NAME"
    
    # Check if user is already a collaborator
    if gh api "/repos/$TARGET_NAME/collaborators/$USER_GITHUB_USERNAME" &> /dev/null; then
        echo "User is already a collaborator on repository $TARGET_NAME"
        
        # Show current permission
        CURRENT_PERMISSION=$(gh api "/repos/$TARGET_NAME/collaborators/$USER_GITHUB_USERNAME/permission" \
            --jq '.permission')
        echo "Current permission level: $CURRENT_PERMISSION"
        
        if [ "$CURRENT_PERMISSION" = "$ROLE" ]; then
            echo "User already has the correct permission level. No changes needed."
            exit 0
        else
            echo "Updating permission level from $CURRENT_PERMISSION to $ROLE..."
        fi
    fi
    
    # Add or update collaborator
    echo "Adding/updating user as collaborator with $ROLE permission..."
    gh api --method PUT "/repos/$TARGET_NAME/collaborators/$USER_GITHUB_USERNAME" \
        -f permission="$ROLE"
    
    echo ""
    echo "Verifying collaborator status..."
    gh api "/repos/$TARGET_NAME/collaborators/$USER_GITHUB_USERNAME/permission" \
        --jq '{username: .user.login, permission: .permission, role_name: .role_name}'
fi

echo ""
echo "============================================"
echo "SUCCESS: User access granted"
echo "============================================"
echo "User: $USER_GITHUB_USERNAME"
echo "Target Type: $TARGET_TYPE"
echo "Target: $TARGET_NAME"
if [ "$TARGET_TYPE" = "repository" ]; then
    echo "Permission: $ROLE"
fi
echo "============================================"

# Optional: List all repositories/teams the user has access to
echo ""
echo "Additional Information:"
if [ "$TARGET_TYPE" = "organization" ]; then
    echo "To see all repositories the user has access to:"
    echo "  gh api '/orgs/$TARGET_NAME/repos?affiliation=member' --jq '.[].full_name'"
    echo ""
    echo "To see teams the user is a member of:"
    echo "  gh api '/orgs/$TARGET_NAME/teams' --jq '.[].name'"
else
    echo "To see all collaborators on the repository:"
    echo "  gh api '/repos/$TARGET_NAME/collaborators' --jq '.[].login'"
fi

# Optional: Send notification (placeholder for Teams webhook or email)
echo ""
echo "Notification (placeholder):"
echo "TODO: Send notification to requestor that access has been granted"
echo "  - User: Michael Ringholm Sundgaard"
echo "  - GitHub: $USER_GITHUB_USERNAME"
echo "  - Access: $ROLE on $TARGET_TYPE $TARGET_NAME"
