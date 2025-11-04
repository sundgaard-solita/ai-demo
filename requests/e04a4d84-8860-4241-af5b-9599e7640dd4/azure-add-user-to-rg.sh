#!/bin/bash
# Bash script to add user to Azure Resource Group using Azure CLI
# Add Michael Ringholm Sundgaard (mrs) to DR3 Resource Group

set -e  # Exit on error

# Configuration - Replace these placeholders with actual values
TENANT_ID="{TENANT_ID}"                      # e.g., "635aa01e-f19d-49ec-8aed-4b2e4312a627"
SUBSCRIPTION_ID="{SUBSCRIPTION_ID}"          # Azure Subscription ID
RESOURCE_GROUP_NAME="DR3"                    # Resource Group name
USER_EMAIL="mrs@solita.dk"                   # User email
ROLE_NAME="Contributor"                      # RBAC role: Reader, Contributor, Owner, etc.

echo "========================================"
echo "Add User to Azure Resource Group"
echo "========================================"
echo ""

echo "Configuration:"
echo "  Tenant ID: $TENANT_ID"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  User Email: $USER_EMAIL"
echo "  Role: $ROLE_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo "Azure CLI version:"
az version --output table
echo ""

# Login to Azure
echo "Logging in to Azure..."
az login --tenant "$TENANT_ID"

# Set subscription
echo "Setting subscription context..."
az account set --subscription "$SUBSCRIPTION_ID"

# Verify subscription
CURRENT_SUB=$(az account show --query name -o tsv)
echo "Current subscription: $CURRENT_SUB"
echo ""

# Verify resource group exists
echo "Verifying resource group exists..."
if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "✓ Resource group '$RESOURCE_GROUP_NAME' found"
else
    echo "ERROR: Resource group '$RESOURCE_GROUP_NAME' not found"
    exit 1
fi
echo ""

# Get user object ID
echo "Getting user object ID..."
USER_OBJECT_ID=$(az ad user show --id "$USER_EMAIL" --query id -o tsv 2>/dev/null || true)

if [ -z "$USER_OBJECT_ID" ]; then
    echo "ERROR: User '$USER_EMAIL' not found in Azure AD"
    exit 1
fi

USER_DISPLAY_NAME=$(az ad user show --id "$USER_EMAIL" --query displayName -o tsv)
echo "✓ User found: $USER_DISPLAY_NAME (ID: $USER_OBJECT_ID)"
echo ""

# Check if user already has the role assignment
echo "Checking existing role assignments..."
EXISTING_ASSIGNMENT=$(az role assignment list \
    --assignee "$USER_OBJECT_ID" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --role "$ROLE_NAME" \
    --query "[0].id" -o tsv 2>/dev/null || true)

if [ -n "$EXISTING_ASSIGNMENT" ]; then
    echo "⚠ User already has '$ROLE_NAME' role on resource group '$RESOURCE_GROUP_NAME'"
    echo "No action needed."
else
    # Assign role to user
    echo "Assigning '$ROLE_NAME' role to user on resource group..."
    az role assignment create \
        --assignee "$USER_OBJECT_ID" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --role "$ROLE_NAME"
    
    echo ""
    echo "✓ Successfully assigned role!"
    echo "  User: $USER_DISPLAY_NAME ($USER_EMAIL)"
    echo "  Role: $ROLE_NAME"
    echo "  Scope: Resource Group '$RESOURCE_GROUP_NAME'"
fi

echo ""
echo "Current role assignments for resource group '$RESOURCE_GROUP_NAME':"
echo "----------------------------------------------------------------------"
az role assignment list --resource-group "$RESOURCE_GROUP_NAME" --output table

echo ""
echo "========================================"
echo "Operation completed successfully!"
echo "========================================"
