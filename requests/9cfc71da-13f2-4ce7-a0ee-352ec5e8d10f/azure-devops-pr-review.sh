#!/bin/bash
# Azure DevOps PR Review Script
# This script can be used to interact with Azure DevOps PRs
#
# Prerequisites:
# - Azure CLI (az) installed and configured
# - Azure DevOps extension installed: az extension add --name azure-devops
# - Authenticated with Azure (az login)
# - Appropriate permissions to access the Azure DevOps organization
#
# Usage:
#   ./azure-devops-pr-review.sh [organization] [project] [repository] [pr-id]
#
# Note: This is a template script. Actual values need to be provided.

set -e

# Configuration (use placeholders that can be updated later)
AZURE_DEVOPS_ORG="${1:-PLACEHOLDER_ORG}"
AZURE_DEVOPS_PROJECT="${2:-PLACEHOLDER_PROJECT}"
AZURE_DEVOPS_REPO="${3:-PLACEHOLDER_REPO}"
PR_ID="${4:-PLACEHOLDER_PR_ID}"
PAT_TOKEN="${AZURE_DEVOPS_PAT:-${AZURE_DEVOPS_EXT_PAT}}"

# Validate inputs
if [[ "$AZURE_DEVOPS_ORG" == "PLACEHOLDER_ORG" ]] || \
   [[ "$AZURE_DEVOPS_PROJECT" == "PLACEHOLDER_PROJECT" ]] || \
   [[ "$AZURE_DEVOPS_REPO" == "PLACEHOLDER_REPO" ]] || \
   [[ "$PR_ID" == "PLACEHOLDER_PR_ID" ]]; then
    echo "⚠️  Usage: $0 <organization> <project> <repository> <pr-id>"
    echo "   Example: $0 solita-denmark my-project my-repo 123"
    echo ""
    echo "   This script will:"
    echo "   1. Fetch PR details from Azure DevOps"
    echo "   2. Display PR status"
    echo "   3. Show reviewers and their votes"
    echo "   4. Display build/pipeline status"
    exit 1
fi

echo "🔍 Fetching PR #${PR_ID} from Azure DevOps..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI (az) is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Azure DevOps extension is installed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q azure-devops; then
    echo "📦 Installing Azure DevOps extension..."
    az extension add --name azure-devops
fi

# Set default organization
az devops configure --defaults organization="https://dev.azure.com/${AZURE_DEVOPS_ORG}" project="${AZURE_DEVOPS_PROJECT}"

echo ""
echo "📋 PR Details:"
az repos pr show --id "$PR_ID" --org "https://dev.azure.com/${AZURE_DEVOPS_ORG}" --project "${AZURE_DEVOPS_PROJECT}"

echo ""
echo "👥 Reviewers:"
az repos pr reviewer list --id "$PR_ID" --org "https://dev.azure.com/${AZURE_DEVOPS_ORG}" --project "${AZURE_DEVOPS_PROJECT}"

echo ""
echo "✅ Build Status:"
az repos pr policy list --id "$PR_ID" --org "https://dev.azure.com/${AZURE_DEVOPS_ORG}" --project "${AZURE_DEVOPS_PROJECT}"

echo ""
echo "💬 To open the PR in your browser:"
PR_URL="https://dev.azure.com/${AZURE_DEVOPS_ORG}/${AZURE_DEVOPS_PROJECT}/_git/${AZURE_DEVOPS_REPO}/pullrequest/${PR_ID}"
echo "   $PR_URL"

echo ""
echo "✅ Script completed successfully!"
