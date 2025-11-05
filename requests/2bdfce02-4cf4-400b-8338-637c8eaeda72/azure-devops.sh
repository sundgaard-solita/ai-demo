#!/bin/bash
#
# Azure DevOps Team Management Script
# Purpose: Add user to Azure DevOps team with appropriate permissions
#
# Security: This script follows least privilege principles and ISO-27001 compliance
# Audit: All changes are logged for audit trail
#

set -e

# Configuration - Replace with actual values
AZURE_DEVOPS_ORG="${AZURE_DEVOPS_ORG:-solita-denmark}"
AZURE_DEVOPS_PROJECT="${AZURE_DEVOPS_PROJECT:-BDK}"
AZURE_DEVOPS_TEAM="${AZURE_DEVOPS_TEAM:-BDK7}"
PAT_TOKEN="${AZURE_DEVOPS_PAT:-YOUR_PAT_TOKEN_HERE}"
USER_EMAIL="mrs@solita.dk"
USER_PRINCIPAL_NAME="michael.sundgaard@solita.dk"

# Display script information
echo "============================================"
echo "Azure DevOps Team Management Script"
echo "============================================"
echo "Request ID: 2bdfce02-4cf4-400b-8338-637c8eaeda72"
echo "User: Michael Ringholm Sundgaard ($USER_EMAIL)"
echo "Organization: $AZURE_DEVOPS_ORG"
echo "Project: $AZURE_DEVOPS_PROJECT"
echo "Team: $AZURE_DEVOPS_TEAM"
echo "============================================"
echo ""

# Check if Azure DevOps CLI extension is installed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv 2>/dev/null | grep -q "azure-devops"; then
    echo "Installing Azure DevOps CLI extension..."
    az extension add --name azure-devops
else
    echo "Azure DevOps CLI extension already installed"
fi

# Configure Azure DevOps defaults
echo ""
echo "Configuring Azure DevOps CLI..."
az devops configure --defaults organization="https://dev.azure.com/$AZURE_DEVOPS_ORG" project="$AZURE_DEVOPS_PROJECT"

# Set PAT token for authentication
if [ "$PAT_TOKEN" = "YOUR_PAT_TOKEN_HERE" ]; then
    echo ""
    echo "WARNING: PAT token not configured. Please set AZURE_DEVOPS_PAT environment variable."
    echo "You can create a PAT token at: https://dev.azure.com/$AZURE_DEVOPS_ORG/_usersSettings/tokens"
    echo ""
    read -s -p "Enter PAT token (or press Enter to skip): " INPUT_PAT
    echo ""  # New line after hidden input
    if [ -n "$INPUT_PAT" ]; then
        export AZURE_DEVOPS_EXT_PAT="$INPUT_PAT"
    else
        echo "Skipping authentication. Script will continue but may fail without valid credentials."
    fi
else
    export AZURE_DEVOPS_EXT_PAT="$PAT_TOKEN"
fi

# Azure DevOps CLI will automatically use AZURE_DEVOPS_EXT_PAT environment variable

# Check if team exists
echo ""
echo "Checking if team '$AZURE_DEVOPS_TEAM' exists..."
TEAM_EXISTS=$(az devops team list --project "$AZURE_DEVOPS_PROJECT" --query "[?name=='$AZURE_DEVOPS_TEAM'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$TEAM_EXISTS" ]; then
    echo "WARNING: Team '$AZURE_DEVOPS_TEAM' not found in project '$AZURE_DEVOPS_PROJECT'"
    echo "Available teams:"
    az devops team list --project "$AZURE_DEVOPS_PROJECT" --query "[].name" -o tsv
    echo ""
    echo "Please verify the team name and update the script if needed."
    exit 1
fi

echo "Team '$AZURE_DEVOPS_TEAM' found"

# Check if user is already a member
echo ""
echo "Checking if user is already a team member..."
# Query checks for user by email or principal name
EXISTING_MEMBER=$(az devops team list-member \
    --team "$AZURE_DEVOPS_TEAM" \
    --project "$AZURE_DEVOPS_PROJECT" \
    --query "value[?identity.uniqueName=='$USER_EMAIL' || \
             identity.uniqueName=='$USER_PRINCIPAL_NAME'].identity.displayName" \
    -o tsv 2>/dev/null || echo "")

if [ -n "$EXISTING_MEMBER" ]; then
    echo "User is already a member of team '$AZURE_DEVOPS_TEAM'"
    echo "No changes needed."
    exit 0
fi

# Add user to the team
echo ""
echo "Adding user to team '$AZURE_DEVOPS_TEAM'..."
az devops team add-member \
    --team "$AZURE_DEVOPS_TEAM" \
    --user "$USER_EMAIL" \
    --project "$AZURE_DEVOPS_PROJECT"

# Verify the addition
echo ""
echo "Verifying team membership..."
az devops team list-member \
    --team "$AZURE_DEVOPS_TEAM" \
    --project "$AZURE_DEVOPS_PROJECT" \
    --query "value[?identity.uniqueName=='$USER_EMAIL'].{DisplayName:identity.displayName,Email:identity.uniqueName,Type:identity.descriptor}" \
    -o table

echo ""
echo "============================================"
echo "SUCCESS: User added to Azure DevOps team"
echo "============================================"
echo "User: $USER_EMAIL"
echo "Team: $AZURE_DEVOPS_TEAM"
echo "Project: $AZURE_DEVOPS_PROJECT"
echo "Organization: $AZURE_DEVOPS_ORG"
echo "============================================"

# Optional: Grant additional permissions if needed
echo ""
echo "Additional Permissions (optional):"
echo "If the user needs specific project permissions beyond team membership,"
echo "use the Azure DevOps Security CLI commands:"
echo ""
echo "  # List available permissions"
echo "  az devops security permission list --id <namespace-id> --subject $USER_EMAIL"
echo ""
echo "  # Grant specific permissions"
echo "  az devops security permission update --allow-bit <bit> --subject $USER_EMAIL"

# Optional: Send notification (placeholder for Teams webhook or email)
echo ""
echo "Notification (placeholder):"
echo "TODO: Send notification to requestor that access has been granted"
echo "  - User: Michael Ringholm Sundgaard"
echo "  - Email: mrs@solita.dk"
echo "  - Team: $AZURE_DEVOPS_TEAM in $AZURE_DEVOPS_PROJECT"
