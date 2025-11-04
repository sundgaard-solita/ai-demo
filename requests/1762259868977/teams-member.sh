#!/bin/bash
#
# Microsoft Teams Management Script
# Purpose: Add user to RIT2 Microsoft Teams Team
# Request ID: 1762259868977
# Date: 2025-11-04
#

set -euo pipefail

# Configuration - UPDATE THESE VALUES
TENANT_ID="${TENANT_ID:-635aa01e-f19d-49ec-8aed-4b2e4312a627}"
TEAM_ID="${TEAM_ID:-PLACEHOLDER_TEAM_ID}"
TEAM_NAME="${TEAM_NAME:-RIT2}"
USER_ID="${USER_ID:-81330d43-ae3b-4bb1-b698-4adacf0e5bca}"
USER_EMAIL="${USER_EMAIL:-michael.sundgaard@solita.dk}"
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
ROLE="${ROLE:-member}"  # Options: owner, member

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Microsoft Teams Management Script"
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

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

print_info "Azure CLI is installed"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_warning "Not logged in to Azure. Attempting login..."
    az login --tenant "$TENANT_ID"
else
    print_info "Already logged in to Azure"
fi

# Verify tenant
CURRENT_TENANT=$(az account show --query tenantId -o tsv)
if [ "$CURRENT_TENANT" != "$TENANT_ID" ]; then
    print_warning "Current tenant ($CURRENT_TENANT) doesn't match expected tenant ($TENANT_ID)"
fi

print_info "Operating in tenant: $TENANT_ID"

# Find team by name if team ID not provided
if [ "$TEAM_ID" = "PLACEHOLDER_TEAM_ID" ]; then
    print_info "Looking up team ID for: $TEAM_NAME"
    print_warning "Team lookup requires Microsoft Graph API call"
    
    # Use REST API to search for team
    ACCESS_TOKEN=$(az account get-access-token --resource=https://graph.microsoft.com --query accessToken -o tsv)
    
    TEAM_SEARCH_RESULT=$(curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://graph.microsoft.com/v1.0/groups?\$filter=resourceProvisioningOptions/Any(x:x eq 'Team') and displayName eq '$TEAM_NAME'")
    
    if command -v jq &> /dev/null; then
        TEAM_ID=$(echo "$TEAM_SEARCH_RESULT" | jq -r '.value[0].id // empty')
    else
        TEAM_ID=$(echo "$TEAM_SEARCH_RESULT" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"//;s/"//')
    fi
    
    if [ -z "$TEAM_ID" ]; then
        print_error "Team '$TEAM_NAME' not found"
        exit 1
    fi
    print_info "Found team: $TEAM_NAME (ID: $TEAM_ID)"
fi

# Get access token for Microsoft Graph
print_info "Getting access token for Microsoft Graph API..."
ACCESS_TOKEN=$(az account get-access-token --resource=https://graph.microsoft.com --query accessToken -o tsv)

# Verify team exists
print_info "Verifying team exists: $TEAM_ID"
TEAM_INFO=$(curl -s -X GET \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    "https://graph.microsoft.com/v1.0/teams/$TEAM_ID")

if command -v jq &> /dev/null; then
    TEAM_DISPLAY_NAME=$(echo "$TEAM_INFO" | jq -r '.displayName // empty')
else
    TEAM_DISPLAY_NAME=$(echo "$TEAM_INFO" | grep -o '"displayName":"[^"]*"' | sed 's/"displayName":"//;s/"//')
fi

if [ -z "$TEAM_DISPLAY_NAME" ]; then
    print_error "Team with ID '$TEAM_ID' not found"
    exit 1
fi

print_info "Team found: $TEAM_DISPLAY_NAME"

# Check if user is already a member
print_info "Checking team membership..."
MEMBERS=$(curl -s -X GET \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    "https://graph.microsoft.com/v1.0/teams/$TEAM_ID/members")

if command -v jq &> /dev/null; then
    IS_MEMBER=$(echo "$MEMBERS" | jq --arg uid "$USER_ID" '[.value[]? | select(.id == $uid)] | length')
else
    IS_MEMBER=$(echo "$MEMBERS" | grep -c "\"id\":\"$USER_ID\"" || echo "0")
fi

if [ "$IS_MEMBER" -gt 0 ]; then
    print_warning "User is already a member of team '$TEAM_DISPLAY_NAME'"
    echo ""
    print_info "Current team members:"
    if command -v jq &> /dev/null; then
        echo "$MEMBERS" | jq -r '.value[]?.displayName // empty' | sort
    else
        echo "$MEMBERS" | grep -o '"displayName":"[^"]*"' | sed 's/"displayName":"//;s/"//g' | sort
    fi
    exit 0
fi

# Add user to team
print_info "Adding user '$USER_DISPLAY_NAME' to team '$TEAM_DISPLAY_NAME' with role '$ROLE'..."

# Prepare JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "@odata.type": "#microsoft.graph.aadUserConversationMember",
  "roles": ["$ROLE"],
  "user@odata.bind": "https://graph.microsoft.com/v1.0/users('$USER_ID')"
}
EOF
)

# Add member using Microsoft Graph API
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" \
    "https://graph.microsoft.com/v1.0/teams/$TEAM_ID/members")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    print_info "✅ Successfully added user to team!"
    echo ""
    echo "Summary:"
    echo "  User: $USER_DISPLAY_NAME"
    echo "  User ID: $USER_ID"
    echo "  Email: $USER_EMAIL"
    echo "  Team: $TEAM_DISPLAY_NAME"
    echo "  Team ID: $TEAM_ID"
    echo "  Role: $ROLE"
    echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    
    # Get updated member list
    print_info "Current team members:"
    UPDATED_MEMBERS=$(curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://graph.microsoft.com/v1.0/teams/$TEAM_ID/members")
    if command -v jq &> /dev/null; then
        echo "$UPDATED_MEMBERS" | jq -r '.value[]?.displayName // empty' | sort
    else
        echo "$UPDATED_MEMBERS" | grep -o '"displayName":"[^"]*"' | sed 's/"displayName":"//;s/"//g' | sort
    fi
    
    # Log the operation (ISO-27001 compliance)
    LOG_FILE="./audit-log.txt"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Added user '$USER_DISPLAY_NAME' ($USER_ID) to Teams team '$TEAM_DISPLAY_NAME' ($TEAM_ID) with role '$ROLE'" >> "$LOG_FILE"
    print_info "Operation logged to: $LOG_FILE"
    
else
    print_error "Failed to add user to team (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

echo ""
echo "================================================"
echo "Operation completed successfully"
echo "================================================"
echo ""
echo "Note: Changes may take a few minutes to propagate in Teams client."
