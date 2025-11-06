#!/bin/bash
# Notification Script for Microsoft Teams
# This script sends a notification to the user after PR review

set -e

# Configuration
REQUEST_ID="99f61942-2006-4948-9f8a-e105286de6b0"
USER_NAME="Michael Ringholm Sundgaard"
USER_ID="81330d43-ae3b-4bb1-b698-4adacf0e5bca"
PR_NUMBER="${1:-unknown}"
ACTION="${2:-reviewed}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Teams Notification Sender${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Request ID: $REQUEST_ID"
echo "User: $USER_NAME"
echo "PR Number: $PR_NUMBER"
echo "Action: $ACTION"
echo ""

# Check if Teams webhook URL is set
if [ -z "$TEAMS_WEBHOOK_URL" ]; then
    echo -e "${RED}Error: TEAMS_WEBHOOK_URL environment variable is not set${NC}"
    echo "Please set it to your Microsoft Teams incoming webhook URL"
    exit 1
fi

# Prompt for custom message
read -p "Enter notification message (or press Enter for default): " CUSTOM_MESSAGE

if [ -z "$CUSTOM_MESSAGE" ]; then
    case $ACTION in
        approved)
            MESSAGE="✅ Your PR #$PR_NUMBER has been approved and is ready to merge!"
            ;;
        merged)
            MESSAGE="🎉 Your PR #$PR_NUMBER has been successfully merged!"
            ;;
        changes_requested)
            MESSAGE="📝 Changes have been requested on your PR #$PR_NUMBER. Please review the feedback."
            ;;
        commented)
            MESSAGE="💬 New comments have been added to your PR #$PR_NUMBER"
            ;;
        *)
            MESSAGE="🔍 Your PR #$PR_NUMBER has been $ACTION"
            ;;
    esac
else
    MESSAGE="$CUSTOM_MESSAGE"
fi

# Prepare Teams message payload
TEAMS_MESSAGE=$(cat <<EOF
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "themeColor": "0076D7",
  "summary": "PR Update Notification",
  "sections": [{
    "activityTitle": "GitHub PR Update",
    "activitySubtitle": "For $USER_NAME",
    "activityImage": "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
    "facts": [{
      "name": "PR Number:",
      "value": "#$PR_NUMBER"
    }, {
      "name": "Action:",
      "value": "$ACTION"
    }, {
      "name": "Request ID:",
      "value": "$REQUEST_ID"
    }],
    "markdown": true,
    "text": "$MESSAGE"
  }],
  "potentialAction": [{
    "@type": "OpenUri",
    "name": "View PR in GitHub",
    "targets": [{
      "os": "default",
      "uri": "https://github.com/sundgaard-solita/ai-demo/pulls"
    }]
  }]
}
EOF
)

# Send notification to Teams
echo -e "${YELLOW}Sending notification to Teams...${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" --connect-timeout 30 --max-time 60 -X POST -H "Content-Type: application/json" -d "$TEAMS_MESSAGE" "$TEAMS_WEBHOOK_URL")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Notification sent successfully to Teams!${NC}"
    echo ""
    echo "Message sent:"
    echo "  → $MESSAGE"
else
    echo -e "${RED}✗ Failed to send notification to Teams${NC}"
    echo "HTTP Status Code: $HTTP_CODE"
    echo "Response: $(echo "$RESPONSE" | head -n-1)"
    exit 1
fi

echo ""
echo -e "${GREEN}Done!${NC}"
