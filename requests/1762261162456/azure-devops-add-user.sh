#!/bin/bash
# Azure DevOps - Add User to Team
# Request ID: 1762261162456
# Description: Add Michael Ringholm Sundgaard (MRS) to RIT5 team

# Configuration
USER_EMAIL="michael.sundgaard@solita.dk"
TEAM_NAME="RIT5"
ORG_URL="https://dev.azure.com/solita"  # Placeholder - update with actual organization URL
PROJECT_NAME="<PROJECT_NAME>"  # Placeholder - update with actual project name
REQUEST_ID="1762261162456"

# Prerequisites:
# - Azure CLI installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# - Azure DevOps extension: az extension add --name azure-devops
# - Authenticated: az login
# - PAT token configured or interactive login

echo "========================================"
echo "Azure DevOps Team Membership Update"
echo "========================================"
echo ""
echo "Request ID: $REQUEST_ID"
echo "User: Michael Ringholm Sundgaard"
echo "Email: $USER_EMAIL"
echo "Target Team: $TEAM_NAME"
echo "Organization: $ORG_URL"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed"
    echo "Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Azure DevOps extension is installed
if ! az extension show --name azure-devops &> /dev/null; then
    echo "Installing Azure DevOps extension..."
    az extension add --name azure-devops
fi

# Set default organization
az devops configure --defaults organization="$ORG_URL"

# Check if project name is provided
if [ "$PROJECT_NAME" = "<PROJECT_NAME>" ]; then
    echo "ERROR: Please update PROJECT_NAME variable with the actual Azure DevOps project name"
    exit 1
fi

echo "Checking if team exists..."
TEAM_EXISTS=$(az devops team list --project "$PROJECT_NAME" --query "[?name=='$TEAM_NAME']" -o tsv)

if [ -z "$TEAM_EXISTS" ]; then
    echo "ERROR: Team '$TEAM_NAME' not found in project '$PROJECT_NAME'"
    exit 1
fi

echo "Found team: $TEAM_NAME"

# Check if user is already a member
echo "Checking current team membership..."
EXISTING_MEMBER=$(az devops team list-member --team "$TEAM_NAME" --project "$PROJECT_NAME" --query "[?user.mailAddress=='$USER_EMAIL']" -o tsv)

if [ -n "$EXISTING_MEMBER" ]; then
    echo "WARNING: User is already a member of team '$TEAM_NAME'"
    exit 0
fi

# Add user to team
echo "Adding user to team..."
az devops team member add \
    --team "$TEAM_NAME" \
    --project "$PROJECT_NAME" \
    --user "$USER_EMAIL"

if [ $? -eq 0 ]; then
    echo ""
    echo "SUCCESS: User successfully added to team '$TEAM_NAME'" 
    echo ""
    echo "Audit Information:"
    echo "- Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "- Request ID: $REQUEST_ID"
    echo "- User: $USER_EMAIL"
    echo "- Team: $TEAM_NAME"
    echo "- Project: $PROJECT_NAME"
    echo "- Organization: $ORG_URL"
else
    echo "ERROR: Failed to add user to team"
    exit 1
fi
