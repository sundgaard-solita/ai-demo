#!/usr/bin/env bash
# Microsoft Teams Notification Script
# This script sends notifications back to Microsoft Teams
#
# Prerequisites:
# - curl installed
# - jq installed (for safe JSON encoding)
# - Teams webhook URL configured
#
# Usage:
#   ./teams-notify.sh "message text"
#
# Note: This is a template script. Webhook URL needs to be configured.

set -e

# Configuration
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL:-PLACEHOLDER_WEBHOOK_URL}"
MESSAGE="${1:-No message provided}"
TITLE="${2:-Notification from AI Demo}"

# Validate webhook URL
if [[ "$TEAMS_WEBHOOK_URL" == "PLACEHOLDER_WEBHOOK_URL" ]]; then
    echo "⚠️  TEAMS_WEBHOOK_URL environment variable is not set"
    echo ""
    echo "Usage:"
    echo "  export TEAMS_WEBHOOK_URL='https://outlook.office.com/webhook/...'"
    echo "  $0 \"Your message here\" \"Optional Title\""
    echo ""
    echo "Or provide it inline:"
    echo "  TEAMS_WEBHOOK_URL='https://...' $0 \"Your message\""
    exit 1
fi

# Check if jq is available for safe JSON encoding
if command -v jq &> /dev/null; then
    # Use jq for safe JSON encoding
    TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    JSON_PAYLOAD=$(jq -n \
        --arg type "MessageCard" \
        --arg context "https://schema.org/extensions" \
        --arg summary "$TITLE" \
        --arg title "$TITLE" \
        --arg subtitle "$TIMESTAMP" \
        --arg text "$MESSAGE" \
        '{
            "@type": $type,
            "@context": $context,
            "summary": $summary,
            "themeColor": "0078D7",
            "title": $title,
            "sections": [{
                "activityTitle": "Automated Message",
                "activitySubtitle": $subtitle,
                "text": $text,
                "markdown": true
            }]
        }')
else
    echo "⚠️  Warning: jq not found. Using basic escaping (install jq for safer JSON handling)"
    # Basic escaping for quotes and backslashes
    MESSAGE_ESCAPED="${MESSAGE//\\/\\\\}"
    MESSAGE_ESCAPED="${MESSAGE_ESCAPED//\"/\\\"}"
    TITLE_ESCAPED="${TITLE//\\/\\\\}"
    TITLE_ESCAPED="${TITLE_ESCAPED//\"/\\\"}"
    TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    JSON_PAYLOAD=$(cat <<EOF
{
  "@type": "MessageCard",
  "@context": "https://schema.org/extensions",
  "summary": "${TITLE_ESCAPED}",
  "themeColor": "0078D7",
  "title": "${TITLE_ESCAPED}",
  "sections": [
    {
      "activityTitle": "Automated Message",
      "activitySubtitle": "${TIMESTAMP}",
      "text": "${MESSAGE_ESCAPED}",
      "markdown": true
    }
  ]
}
EOF
)
fi

echo "📤 Sending notification to Microsoft Teams..."
echo "Message: ${MESSAGE}"

# Send notification to Teams
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "${JSON_PAYLOAD}" \
    "${TEAMS_WEBHOOK_URL}")

if [ "$RESPONSE" == "1" ]; then
    echo "✅ Notification sent successfully to Teams!"
else
    echo "❌ Failed to send notification. Response: ${RESPONSE}"
    exit 1
fi
