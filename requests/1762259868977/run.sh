#!/bin/bash
#
# Master Script - Request 1762259868977
# Purpose: Interactive menu to add Michael Ringholm Sundgaard (mrs) to RIT2
# Date: 2025-11-04
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Request Management Tool${NC}"
echo -e "${BLUE}   Request ID: 1762259868977${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Task:${NC} Add Michael Ringholm Sundgaard (mrs) to RIT2"
echo -e "${GREEN}Date:${NC} 2025-11-04T12:37:48.977Z"
echo ""
echo "This tool helps you add a user to various platforms."
echo "Please select the type of resource 'RIT2' represents:"
echo ""
echo "1) Azure AD Security Group"
echo "2) Azure Resource Group (RBAC)"
echo "3) Azure DevOps Project"
echo "4) GitHub Team"
echo "5) Microsoft Teams Team"
echo "6) All of the above (Full provisioning)"
echo "7) View request details"
echo "8) Exit"
echo ""
read -p "Enter your choice [1-8]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Executing: Azure AD Group Management${NC}"
        echo ""
        ./azure-ad-group.sh
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Executing: Azure RBAC Management${NC}"
        echo ""
        ./azure-rbac.sh
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Executing: Azure DevOps Project Management${NC}"
        echo ""
        ./azure-devops.sh
        ;;
    4)
        echo ""
        echo -e "${YELLOW}Executing: GitHub Team Management${NC}"
        echo ""
        ./github-team.sh
        ;;
    5)
        echo ""
        echo -e "${YELLOW}Executing: Microsoft Teams Management${NC}"
        echo ""
        ./teams-member.sh
        ;;
    6)
        echo ""
        echo -e "${YELLOW}Executing: Full Provisioning${NC}"
        echo -e "${YELLOW}This will attempt to add the user to all platforms${NC}"
        echo ""
        read -p "Are you sure? [y/N]: " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            echo ""
            echo "1/5 - Azure AD Group"
            ./azure-ad-group.sh || echo "Failed or skipped"
            echo ""
            echo "2/5 - Azure Resource Group"
            ./azure-rbac.sh || echo "Failed or skipped"
            echo ""
            echo "3/5 - Azure DevOps"
            ./azure-devops.sh || echo "Failed or skipped"
            echo ""
            echo "4/5 - GitHub Team"
            ./github-team.sh || echo "Failed or skipped"
            echo ""
            echo "5/5 - Microsoft Teams"
            ./teams-member.sh || echo "Failed or skipped"
            echo ""
            echo -e "${GREEN}Full provisioning completed!${NC}"
        else
            echo "Cancelled"
        fi
        ;;
    7)
        echo ""
        cat README.md
        echo ""
        read -p "Press Enter to continue..."
        exec "$0"
        ;;
    8)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run the script again.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Operation completed!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Verify the operation completed successfully"
echo "  2. Notify the requester: Michael Ringholm Sundgaard"
echo "  3. Update the issue status in GitHub"
echo "  4. Check the audit log: ./audit-log.txt"
echo ""
