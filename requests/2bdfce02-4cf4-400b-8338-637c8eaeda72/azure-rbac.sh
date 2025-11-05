#!/bin/bash
#
# Azure RBAC Management Script
# Purpose: Add user to Azure subscription or resource group with appropriate permissions
#
# Security: This script follows least privilege principles and ISO-27001 compliance
# Audit: All changes are logged for audit trail
#

set -e

# Configuration - Replace with actual values
TENANT_ID="${AZURE_TENANT_ID:-635aa01e-f19d-49ec-8aed-4b2e4312a627}"
SUBSCRIPTION_NAME_OR_ID="${SUBSCRIPTION_NAME_OR_ID:-BDK7}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-BDK7}"
USER_EMAIL="mrs@solita.dk"
USER_PRINCIPAL_NAME="${USER_EMAIL}"
ROLE="${AZURE_ROLE:-Reader}" # Options: Owner, Contributor, Reader

# Display script information
echo "============================================"
echo "Azure RBAC Management Script"
echo "============================================"
echo "Request ID: 2bdfce02-4cf4-400b-8338-637c8eaeda72"
echo "User: Michael Ringholm Sundgaard ($USER_EMAIL)"
echo "Target: $SUBSCRIPTION_NAME_OR_ID / $RESOURCE_GROUP_NAME"
echo "Role: $ROLE"
echo "============================================"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Login to Azure (if not already logged in)
echo "Checking Azure authentication..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login --tenant "$TENANT_ID"
else
    echo "Already authenticated to Azure"
fi

# Set the subscription context
echo ""
echo "Setting subscription context..."
az account set --subscription "$SUBSCRIPTION_NAME_OR_ID"

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Check if BDK7 is a subscription or resource group
echo ""
echo "Determining if BDK7 is a subscription or resource group..."

# Try to find resource group
if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "BDK7 is a resource group"
    SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
    SCOPE_TYPE="Resource Group"
else
    echo "BDK7 is a subscription (or resource group not found, using subscription scope)"
    SCOPE="/subscriptions/$SUBSCRIPTION_ID"
    SCOPE_TYPE="Subscription"
fi

# Check if user already has the role assignment
echo ""
echo "Checking existing role assignments for user..."
if az role assignment list \
    --assignee "$USER_EMAIL" \
    --scope "$SCOPE" \
    --role "$ROLE" \
    --query "[].roleDefinitionName" -o tsv > /dev/null 2>&1; then
    EXISTING_ROLE=$(az role assignment list \
        --assignee "$USER_EMAIL" \
        --scope "$SCOPE" \
        --role "$ROLE" \
        --query "[].roleDefinitionName" -o tsv)
else
    EXISTING_ROLE=""
fi

if [ -n "$EXISTING_ROLE" ]; then
    echo "User already has $ROLE role on $SCOPE_TYPE: $SCOPE"
    echo "No changes needed."
    exit 0
fi

# Assign the role to the user
echo ""
echo "Assigning $ROLE role to user at scope: $SCOPE"
az role assignment create \
    --assignee "$USER_EMAIL" \
    --role "$ROLE" \
    --scope "$SCOPE"

# Verify the assignment
echo ""
echo "Verifying role assignment..."
az role assignment list \
    --assignee "$USER_EMAIL" \
    --scope "$SCOPE" \
    --query "[].{Role:roleDefinitionName,Scope:scope,Principal:principalName}" \
    -o table

echo ""
echo "============================================"
echo "SUCCESS: User access granted"
echo "============================================"
echo "User: $USER_EMAIL"
echo "Role: $ROLE"
echo "Scope Type: $SCOPE_TYPE"
echo "Scope: $SCOPE"
echo "============================================"

# Optional: Send notification (placeholder for Teams webhook or email)
echo ""
echo "Notification (placeholder):"
echo "TODO: Send notification to requestor that access has been granted"
echo "  - User: Michael Ringholm Sundgaard"
echo "  - Email: mrs@solita.dk"
echo "  - Access: $ROLE on $SCOPE_TYPE BDK7"
