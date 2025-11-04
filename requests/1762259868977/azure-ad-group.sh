#!/bin/bash
#
# Azure AD Group Management Script
# Purpose: Add user Michael Ringholm Sundgaard to RIT2 Azure AD Security Group
# Request ID: 1762259868977
# Date: 2025-11-04
#

set -euo pipefail

# Configuration - UPDATE THESE VALUES
TENANT_ID="${TENANT_ID:-635aa01e-f19d-49ec-8aed-4b2e4312a627}"
USER_OBJECT_ID="${USER_OBJECT_ID:-81330d43-ae3b-4bb1-b698-4adacf0e5bca}"
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
GROUP_NAME="${GROUP_NAME:-RIT2}"
GROUP_OBJECT_ID="${GROUP_OBJECT_ID:-PLACEHOLDER_GROUP_OBJECT_ID}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Azure AD Group Management Script"
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
    print_info "Switching to correct tenant..."
    az account set --subscription "$(az account list --query "[?tenantId=='$TENANT_ID'].id | [0]" -o tsv)"
fi

print_info "Operating in tenant: $TENANT_ID"

# Find the group by name if object ID not provided
if [ "$GROUP_OBJECT_ID" = "PLACEHOLDER_GROUP_OBJECT_ID" ]; then
    print_info "Looking up group object ID for: $GROUP_NAME"
    GROUP_OBJECT_ID=$(az ad group list --filter "displayName eq '$GROUP_NAME'" --query "[0].id" -o tsv)
    
    if [ -z "$GROUP_OBJECT_ID" ] || [ "$GROUP_OBJECT_ID" = "null" ]; then
        print_error "Group '$GROUP_NAME' not found in Azure AD"
        exit 1
    fi
    print_info "Found group: $GROUP_NAME (ID: $GROUP_OBJECT_ID)"
fi

# Verify user exists
print_info "Verifying user exists: $USER_DISPLAY_NAME"
USER_CHECK=$(az ad user show --id "$USER_OBJECT_ID" --query "displayName" -o tsv 2>/dev/null || echo "")

if [ -z "$USER_CHECK" ]; then
    print_error "User with object ID '$USER_OBJECT_ID' not found"
    exit 1
fi

print_info "User found: $USER_CHECK"

# Check if user is already a member
print_info "Checking current group membership..."
IS_MEMBER=$(az ad group member check --group "$GROUP_OBJECT_ID" --member-id "$USER_OBJECT_ID" --query "value" -o tsv)

if [ "$IS_MEMBER" = "true" ]; then
    print_warning "User is already a member of group '$GROUP_NAME'"
    echo ""
    echo "Current members of group '$GROUP_NAME':"
    az ad group member list --group "$GROUP_OBJECT_ID" --query "[].{Name:displayName, Email:mail, ID:id}" -o table
    exit 0
fi

# Add user to group
print_info "Adding user '$USER_DISPLAY_NAME' to group '$GROUP_NAME'..."

if az ad group member add \
    --group "$GROUP_OBJECT_ID" \
    --member-id "$USER_OBJECT_ID"; then
    
    print_info "✅ Successfully added user to group!"
    echo ""
    echo "Summary:"
    echo "  User: $USER_DISPLAY_NAME"
    echo "  User ID: $USER_OBJECT_ID"
    echo "  Group: $GROUP_NAME"
    echo "  Group ID: $GROUP_OBJECT_ID"
    echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    
    # Display updated group members
    print_info "Current members of group '$GROUP_NAME':"
    az ad group member list --group "$GROUP_OBJECT_ID" --query "[].{Name:displayName, Email:mail, ID:id}" -o table
    
    # Log the operation (ISO-27001 compliance)
    LOG_FILE="./audit-log.txt"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Added user '$USER_DISPLAY_NAME' ($USER_OBJECT_ID) to group '$GROUP_NAME' ($GROUP_OBJECT_ID)" >> "$LOG_FILE"
    print_info "Operation logged to: $LOG_FILE"
    
else
    print_error "Failed to add user to group"
    exit 1
fi

echo ""
echo "================================================"
echo "Operation completed successfully"
echo "================================================"
