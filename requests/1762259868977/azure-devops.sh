#!/bin/bash
#
# Azure DevOps Project Management Script
# Purpose: Add user to RIT2 Azure DevOps Project
# Request ID: 1762259868977
# Date: 2025-11-04
#

set -euo pipefail

# Configuration - UPDATE THESE VALUES
ORGANIZATION="${AZURE_DEVOPS_ORG:-solita-denmark}"
PROJECT_NAME="${PROJECT_NAME:-RIT2}"
USER_EMAIL="${USER_EMAIL:-michael.sundgaard@solita.dk}"
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
ACCESS_LEVEL="${ACCESS_LEVEL:-Basic}"  # Options: Basic, Stakeholder, Advanced
PAT_TOKEN="${AZURE_DEVOPS_PAT:-PLACEHOLDER_PAT_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Azure DevOps Project Management Script"
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

# Check if Azure DevOps CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

print_info "Azure CLI is installed"

# Check if Azure DevOps extension is installed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    print_warning "Azure DevOps extension not installed. Installing..."
    az extension add --name azure-devops
fi

print_info "Azure DevOps extension is available"

# Set PAT token
if [ "$PAT_TOKEN" = "PLACEHOLDER_PAT_TOKEN" ]; then
    print_error "PAT token not configured. Please set AZURE_DEVOPS_PAT environment variable."
    echo ""
    echo "To generate a PAT token:"
    echo "1. Go to: https://dev.azure.com/$ORGANIZATION/_usersSettings/tokens"
    echo "2. Create a new token with 'Member Entitlement Management' (Read & Write) scope"
    echo "3. Export it: export AZURE_DEVOPS_PAT='your-token-here'"
    exit 1
fi

# Set default organization
az devops configure --defaults organization="https://dev.azure.com/$ORGANIZATION"
print_info "Default organization set to: $ORGANIZATION"

# Set default project
az devops configure --defaults project="$PROJECT_NAME"
print_info "Default project set to: $PROJECT_NAME"

# Verify project exists
print_info "Verifying project: $PROJECT_NAME"
PROJECT_ID=$(az devops project show --project "$PROJECT_NAME" --query "id" -o tsv 2>/dev/null || echo "")

if [ -z "$PROJECT_ID" ]; then
    print_error "Project '$PROJECT_NAME' not found in organization '$ORGANIZATION'"
    echo ""
    echo "Available projects:"
    az devops project list --query "[].{Name:name, State:state}" -o table
    exit 1
fi

print_info "Project found: $PROJECT_NAME (ID: $PROJECT_ID)"

# Check if user already has access
print_info "Checking if user already has access..."
USER_EXISTS=$(az devops user show --user "$USER_EMAIL" --query "user.principalName" -o tsv 2>/dev/null || echo "")

if [ -n "$USER_EXISTS" ]; then
    print_warning "User '$USER_EMAIL' already exists in organization"
    
    # Show user details
    echo ""
    print_info "User details:"
    az devops user show --user "$USER_EMAIL" --query "{Email:user.principalName, DisplayName:user.displayName, AccessLevel:accessLevel.accountLicenseType}" -o table
    
    # Check team membership
    print_info "Checking team memberships in project '$PROJECT_NAME'..."
    az devops team list --project "$PROJECT_NAME" --query "[].{Name:name, Description:description}" -o table
else
    # Add user to organization
    print_info "Adding user '$USER_DISPLAY_NAME' ($USER_EMAIL) to organization..."
    
    if az devops user add \
        --email-id "$USER_EMAIL" \
        --license-type "$ACCESS_LEVEL" \
        --query "{Email:user.principalName, DisplayName:user.displayName, AccessLevel:accessLevel.accountLicenseType}" -o table; then
        
        print_info "✅ User added to organization successfully!"
    else
        print_error "Failed to add user to organization"
        exit 1
    fi
fi

# Add user to project team (optional - usually inherited from organization access)
print_info "Note: Project access is typically inherited from organization-level permissions."
print_info "To add user to a specific team within the project, use:"
echo "  az devops team list --project '$PROJECT_NAME' --query '[].name' -o tsv"
echo "  az devops security group membership add --group-id [team-id] --member-id '$USER_EMAIL'"

echo ""
echo "Summary:"
echo "  User: $USER_DISPLAY_NAME"
echo "  Email: $USER_EMAIL"
echo "  Organization: $ORGANIZATION"
echo "  Project: $PROJECT_NAME"
echo "  Access Level: $ACCESS_LEVEL"
echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Log the operation (ISO-27001 compliance)
LOG_FILE="./audit-log.txt"
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Added user '$USER_DISPLAY_NAME' ($USER_EMAIL) to Azure DevOps project '$PROJECT_NAME' in organization '$ORGANIZATION'" >> "$LOG_FILE"
print_info "Operation logged to: $LOG_FILE"

echo ""
echo "================================================"
echo "Operation completed successfully"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Verify user received invitation email"
echo "2. User should accept the invitation"
echo "3. Add user to specific teams if needed"
echo "4. Configure project-level permissions if needed"
