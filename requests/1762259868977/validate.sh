#!/bin/bash
#
# Validation Script for Request 1762259868977
# Purpose: Validate all scripts and configuration before execution
# Date: 2025-11-04
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Request Validation Tool${NC}"
echo -e "${BLUE}   Request ID: 1762259868977${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# Function to print test results
print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "Running validation checks..."
echo ""

# Check if all required files exist
echo "1. Checking file structure..."
FILES=(
    "README.md"
    "QUICKSTART.md"
    "config.env"
    "run.sh"
    "azure-ad-group.sh"
    "azure-rbac.sh"
    "azure-devops.sh"
    "github-team.sh"
    "teams-member.sh"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        print_pass "File exists: $file"
    else
        print_fail "File missing: $file"
    fi
done

echo ""

# Check if scripts are executable
echo "2. Checking script permissions..."
SCRIPTS=(
    "run.sh"
    "azure-ad-group.sh"
    "azure-rbac.sh"
    "azure-devops.sh"
    "github-team.sh"
    "teams-member.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        print_pass "Executable: $script"
    else
        print_fail "Not executable: $script (run: chmod +x $script)"
    fi
done

echo ""

# Check bash syntax
echo "3. Checking script syntax..."
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            print_pass "Syntax valid: $script"
        else
            print_fail "Syntax error: $script"
        fi
    fi
done

echo ""

# Check for required tools
echo "4. Checking required tools..."

if command -v az &> /dev/null; then
    print_pass "Azure CLI is installed"
else
    print_warn "Azure CLI not found (required for Azure operations)"
fi

if command -v gh &> /dev/null; then
    print_pass "GitHub CLI is installed"
else
    print_warn "GitHub CLI not found (required for GitHub operations)"
fi

if command -v curl &> /dev/null; then
    print_pass "curl is installed"
else
    print_fail "curl not found (required for Teams operations)"
fi

if command -v jq &> /dev/null; then
    print_pass "jq is installed"
else
    print_warn "jq not found (helpful for JSON processing)"
fi

echo ""

# Check configuration
echo "5. Checking configuration..."

if [ -f "config.env" ]; then
    source config.env
    
    if [ -n "${USER_OBJECT_ID:-}" ]; then
        print_pass "User object ID is configured"
    else
        print_fail "USER_OBJECT_ID not set in config.env"
    fi
    
    if [ -n "${TENANT_ID:-}" ]; then
        print_pass "Tenant ID is configured"
    else
        print_fail "TENANT_ID not set in config.env"
    fi
    
    if [[ "${SUBSCRIPTION_ID:-}" == *"PLACEHOLDER"* ]]; then
        print_warn "SUBSCRIPTION_ID contains placeholder value"
    fi
    
    if [[ "${GROUP_OBJECT_ID:-}" == *"PLACEHOLDER"* ]]; then
        print_warn "GROUP_OBJECT_ID contains placeholder value (will be auto-detected)"
    fi
fi

echo ""

# Check authentication status
echo "6. Checking authentication..."

if command -v az &> /dev/null; then
    if az account show &> /dev/null; then
        CURRENT_TENANT=$(az account show --query tenantId -o tsv)
        if [ "${CURRENT_TENANT}" = "635aa01e-f19d-49ec-8aed-4b2e4312a627" ]; then
            print_pass "Logged in to correct Azure tenant"
        else
            print_warn "Logged in to Azure but different tenant ($CURRENT_TENANT)"
        fi
    else
        print_warn "Not logged in to Azure (run: az login)"
    fi
fi

if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null 2>&1; then
        print_pass "Authenticated to GitHub"
    else
        print_warn "Not authenticated to GitHub (run: gh auth login)"
    fi
fi

echo ""

# Check environment variables
echo "7. Checking environment variables..."

if [ -n "${AZURE_DEVOPS_PAT:-}" ]; then
    print_pass "AZURE_DEVOPS_PAT is set"
else
    print_warn "AZURE_DEVOPS_PAT not set (required for Azure DevOps operations)"
fi

if [ -n "${GITHUB_PAT:-}" ]; then
    print_pass "GITHUB_PAT is set"
else
    print_warn "GITHUB_PAT not set (required for GitHub operations)"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo "Validation Summary:"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Validation failed. Please fix the errors above before proceeding.${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Validation passed with warnings. Review warnings before proceeding.${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All checks passed! Ready to execute scripts.${NC}"
    exit 0
fi
