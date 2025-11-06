#!/bin/bash
# Script to notify Teams when PR review is completed
# This script would send a message back to the Teams channel confirming PR review completion

# Configuration
REQUEST_ID="e65b61c2-2506-4d05-8d67-06943dca9742"
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL:-PLACEHOLDER_WEBHOOK_URL}"
TENANT_ID="${TENANT_ID:-635aa01e-f19d-49ec-8aed-4b2e4312a627}"
CHANNEL_ID="19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"
TEAM_ID="45500773-64be-4e45-9aeb-0922cdb2f616"

# Message to send
MESSAGE="PR review completed for request ${REQUEST_ID}. Changes have been reviewed and approved."

echo "=== PR Review Notification Script ==="
echo "Request ID: ${REQUEST_ID}"
echo "Team ID: ${TEAM_ID}"
echo "Channel ID: ${CHANNEL_ID}"
echo ""

# Check if webhook URL is configured
if [ "${TEAMS_WEBHOOK_URL}" = "PLACEHOLDER_WEBHOOK_URL" ]; then
    echo "⚠️  WARNING: TEAMS_WEBHOOK_URL not configured"
    echo "Please set the TEAMS_WEBHOOK_URL environment variable to enable notifications"
    echo ""
    echo "Example:"
    echo "  export TEAMS_WEBHOOK_URL='https://outlook.office.com/webhook/...'"
    echo "  ./notify-completion.sh"
    exit 1
fi

# Prepare JSON payload for Teams
PAYLOAD=$(cat <<EOF
{
    "@type": "MessageCard",
    "@context": "https://schema.org/extensions",
    "summary": "PR Review Completed",
    "themeColor": "0078D7",
    "title": "✅ Pull Request Review Completed",
    "sections": [
        {
            "activityTitle": "Code Review Status Update",
            "activitySubtitle": "Request ID: ${REQUEST_ID}",
            "facts": [
                {
                    "name": "Status:",
                    "value": "Approved"
                },
                {
                    "name": "Request ID:",
                    "value": "${REQUEST_ID}"
                },
                {
                    "name": "Timestamp:",
                    "value": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                }
            ],
            "text": "${MESSAGE}"
        }
    ]
}
EOF
)

# Send notification to Teams
echo "Sending notification to Teams..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${TEAMS_WEBHOOK_URL}" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}")

HTTP_CODE=$(echo "${RESPONSE}" | tail -n1)
BODY=$(echo "${RESPONSE}" | head -n-1)

if [ "${HTTP_CODE}" = "200" ]; then
    echo "✅ Notification sent successfully!"
    echo "Response: ${BODY}"
else
    echo "❌ Failed to send notification"
    echo "HTTP Status: ${HTTP_CODE}"
    echo "Response: ${BODY}"
    exit 1
fi

echo ""
echo "=== Notification Complete ==="
