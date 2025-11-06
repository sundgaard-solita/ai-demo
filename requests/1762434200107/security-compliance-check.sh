#!/bin/bash
# Security and Compliance Check Script
# Purpose: Verify security and ISO-27001 compliance for request 1762434200107

set -e

# Configuration
GITHUB_TOKEN="${PAT_TOKEN:-$GITHUB_TOKEN}"
GITHUB_REPO="${GITHUB_REPOSITORY:-sundgaard-solita/ai-demo}"
REQUEST_ID="1762434200107"
REPORT_FILE="/tmp/compliance-report-${REQUEST_ID}.md"

# Validate required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN or PAT_TOKEN is required"
    exit 1
fi

echo "🔒 Starting security and compliance checks..."
echo ""

# Initialize report
cat > "$REPORT_FILE" <<EOF
# Security & Compliance Report
**Request ID:** $REQUEST_ID  
**Date:** $(date -u +%Y-%m-%d\ %H:%M:%S) UTC  
**Repository:** $GITHUB_REPO

---

## ISO-27001 Compliance Checks

EOF

# Check 1: Verify no secrets in code
echo "🔍 Checking for secrets in code..."
if command -v git-secrets &> /dev/null; then
    git secrets --scan 2>&1 | tee -a "$REPORT_FILE" || echo "⚠️  git-secrets not configured"
else
    echo "### Secret Scanning" >> "$REPORT_FILE"
    echo "⚠️ git-secrets not installed. Recommend installing for automatic secret detection." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# Check 2: Verify .gitignore exists and is properly configured
echo "🔍 Checking .gitignore configuration..."
if [ -f ".gitignore" ]; then
    echo "### .gitignore Configuration" >> "$REPORT_FILE"
    echo "✅ .gitignore file exists" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for common sensitive patterns
    PATTERNS=("*.env" "*.key" "*.pem" "*.p12" "secrets/" "credentials/")
    for pattern in "${PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            echo "  - ✅ Pattern \`$pattern\` is ignored" >> "$REPORT_FILE"
        else
            echo "  - ⚠️  Pattern \`$pattern\` not found in .gitignore" >> "$REPORT_FILE"
        fi
    done
    echo "" >> "$REPORT_FILE"
else
    echo "### .gitignore Configuration" >> "$REPORT_FILE"
    echo "❌ .gitignore file missing - this is a security risk!" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# Check 3: Verify branch protection
echo "🔍 Checking branch protection rules..."
echo "### Branch Protection" >> "$REPORT_FILE"
if command -v gh &> /dev/null; then
    BRANCH_PROTECTION=$(gh api "/repos/$GITHUB_REPO/branches/main/protection" 2>&1 || echo "not protected")
    if [[ "$BRANCH_PROTECTION" == *"not protected"* ]]; then
        echo "⚠️  Main branch is not protected. Consider enabling branch protection." >> "$REPORT_FILE"
    else
        echo "✅ Branch protection is enabled" >> "$REPORT_FILE"
    fi
else
    echo "⚠️  GitHub CLI not available for branch protection check" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Check 4: Verify security policies
echo "🔍 Checking security policies..."
echo "### Security Policies" >> "$REPORT_FILE"
if [ -f "SECURITY.md" ]; then
    echo "✅ SECURITY.md file exists" >> "$REPORT_FILE"
else
    echo "⚠️  SECURITY.md file missing - recommend creating security policy" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Check 5: License check
echo "🔍 Checking license..."
echo "### License" >> "$REPORT_FILE"
if [ -f "LICENSE" ]; then
    echo "✅ LICENSE file exists" >> "$REPORT_FILE"
else
    echo "⚠️  LICENSE file missing" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Check 6: Least privilege check (for workflow files)
echo "🔍 Checking workflow permissions..."
echo "### Workflow Permissions (Least Privilege)" >> "$REPORT_FILE"
if [ -d ".github/workflows" ]; then
    WORKFLOWS=$(find .github/workflows -name "*.yml" -o -name "*.yaml")
    for workflow in $WORKFLOWS; do
        echo "**File:** \`$(basename "$workflow")\`" >> "$REPORT_FILE"
        if grep -q "permissions:" "$workflow"; then
            echo "  - ✅ Explicit permissions defined" >> "$REPORT_FILE"
            grep -A 5 "permissions:" "$workflow" | sed 's/^/    /' >> "$REPORT_FILE"
        else
            echo "  - ⚠️  No explicit permissions defined (using defaults)" >> "$REPORT_FILE"
        fi
        echo "" >> "$REPORT_FILE"
    done
else
    echo "⚠️  No workflow files found" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Summary
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The security and compliance check has been completed. Please review any warnings above." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Key ISO-27001 Requirements:**" >> "$REPORT_FILE"
echo "- ✓ Access Control: Verify least privilege in workflows" >> "$REPORT_FILE"
echo "- ✓ Cryptography: Ensure no secrets in code" >> "$REPORT_FILE"
echo "- ✓ Operations Security: Branch protection and security policies" >> "$REPORT_FILE"
echo "- ✓ Information Security: Proper .gitignore configuration" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Display the report
echo ""
echo "📊 Compliance Report Generated:"
cat "$REPORT_FILE"

echo ""
echo "📝 Full report saved to: $REPORT_FILE"
