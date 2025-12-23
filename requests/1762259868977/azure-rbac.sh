#!/bin/bash
#
# Azure RBAC Management Script
# Purpose: Grant user permissions to RIT2 Azure Resource Group
# Request ID: 1762259868977
# Date: 2025-11-04
#

set -euo pipefail

# Configuration - UPDATE THESE VALUES
TENANT_ID="${TENANT_ID:-635aa01e-f19d-49ec-8aed-4b2e4312a627}"
USER_OBJECT_ID="${USER_OBJECT_ID:-81330d43-ae3b-4bb1-b698-4adacf0e5bca}"
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
RESOURCE_GROUP="${RESOURCE_GROUP:-RIT2}"
ROLE="${ROLE:-Contributor}"  # Options: Reader, Contributor, Owner
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-PLACEHOLDER_SUBSCRIPTION_ID}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Azure RBAC Management Script"
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

# Set subscription if provided
if [ "$SUBSCRIPTION_ID" != "PLACEHOLDER_SUBSCRIPTION_ID" ]; then
    print_info "Setting subscription: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
else
    print_warning "Using current subscription"
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    print_info "Current subscription: $SUBSCRIPTION_ID"
fi

# Verify tenant
CURRENT_TENANT=$(az account show --query tenantId -o tsv)
if [ "$CURRENT_TENANT" != "$TENANT_ID" ]; then
    print_error "Current tenant ($CURRENT_TENANT) doesn't match expected tenant ($TENANT_ID)"
    exit 1
fi

print_info "Operating in tenant: $TENANT_ID"

# Verify resource group exists
print_info "Verifying resource group: $RESOURCE_GROUP"
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_error "Resource group '$RESOURCE_GROUP' not found"
    exit 1
fi

print_info "Resource group found: $RESOURCE_GROUP"

# Get resource group details
RG_LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)
print_info "Resource group location: $RG_LOCATION"

# Verify user exists
print_info "Verifying user exists: $USER_DISPLAY_NAME"
USER_CHECK=$(az ad user show --id "$USER_OBJECT_ID" --query "displayName" -o tsv 2>/dev/null || echo "")

if [ -z "$USER_CHECK" ]; then
    print_error "User with object ID '$USER_OBJECT_ID' not found"
    exit 1
fi

print_info "User found: $USER_CHECK"

# Check if role assignment already exists
print_info "Checking existing role assignments..."
EXISTING_ASSIGNMENT=$(az role assignment list \
    --assignee "$USER_OBJECT_ID" \
    --resource-group "$RESOURCE_GROUP" \
    --role "$ROLE" \
    --query "[0].id" -o tsv 2>/dev/null || echo "")

if [ -n "$EXISTING_ASSIGNMENT" ]; then
    print_warning "User already has '$ROLE' role on resource group '$RESOURCE_GROUP'"
    echo ""
    echo "Current role assignments for user in this resource group:"
    az role assignment list \
        --assignee "$USER_OBJECT_ID" \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{Role:roleDefinitionName, Scope:scope}" -o table
    exit 0
fi

# Create role assignment
print_info "Granting '$ROLE' role to user '$USER_DISPLAY_NAME' on resource group '$RESOURCE_GROUP'..."

if az role assignment create \
    --assignee "$USER_OBJECT_ID" \
    --role "$ROLE" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Role:roleDefinitionName, User:principalId, Scope:scope}" -o table; then
    
    print_info "✅ Successfully granted permissions!"
    echo ""
    echo "Summary:"
    echo "  User: $USER_DISPLAY_NAME"
    echo "  User ID: $USER_OBJECT_ID"
    echo "  Resource Group: $RESOURCE_GROUP"
    echo "  Location: $RG_LOCATION"
    echo "  Role: $ROLE"
    echo "  Subscription: $SUBSCRIPTION_ID"
    echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    
    # Display all role assignments for this user in the resource group
    print_info "All role assignments for user in resource group '$RESOURCE_GROUP':"
    az role assignment list \
        --assignee "$USER_OBJECT_ID" \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{Role:roleDefinitionName, Scope:scope}" -o table
    
    # Log the operation (ISO-27001 compliance)
    LOG_FILE="./audit-log.txt"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Granted '$ROLE' role to user '$USER_DISPLAY_NAME' ($USER_OBJECT_ID) on resource group '$RESOURCE_GROUP'" >> "$LOG_FILE"
    print_info "Operation logged to: $LOG_FILE"
    
else
    print_error "Failed to grant permissions"
    exit 1
fi

echo ""
echo "================================================"
echo "Operation completed successfully"
echo "================================================"
echo ""
echo "Note: Role assignments may take a few minutes to propagate."
echo "User should sign out and sign back in for changes to take effect."
