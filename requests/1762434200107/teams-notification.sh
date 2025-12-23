#!/bin/bash
# Teams Notification Script
# Purpose: Send status updates to Teams channel for request 1762434200107

set -e

# Configuration
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL}"
REQUEST_ID="1762434200107"
CHANNEL_ID="19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"
TEAM_ID="45500773-64be-4e45-9aeb-0922cdb2f616"

# Validate required environment variables
if [ -z "$TEAMS_WEBHOOK_URL" ]; then
    echo "Error: TEAMS_WEBHOOK_URL is required"
    echo "Please set the Teams webhook URL as an environment variable"
    exit 1
fi

# Function to send Teams notification
send_teams_notification() {
    local message="$1"
    local status_icon="$2"
    
    local payload=$(cat <<EOF
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "summary": "GitHub PR Status Update",
  "themeColor": "0076D7",
  "title": "${status_icon} GitHub PR Status Update",
  "sections": [{
    "activityTitle": "Request ID: ${REQUEST_ID}",
    "activitySubtitle": "$(date -u +%Y-%m-%d\ %H:%M:%S) UTC",
    "text": "${message}",
    "markdown": true
  }],
  "potentialAction": [{
    "@type": "OpenUri",
    "name": "View in GitHub",
    "targets": [{
      "os": "default",
      "uri": "https://github.com/sundgaard-solita/ai-demo/pulls"
    }]
  }]
}
EOF
)

    echo "📤 Sending notification to Teams..."
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$TEAMS_WEBHOOK_URL")
    
    if [ "$response" = "1" ]; then
        echo "✅ Teams notification sent successfully"
    else
        echo "⚠️  Teams notification response: $response"
    fi
}

# Main execution
case "${1:-status}" in
    "started")
        send_teams_notification "🚀 Automated PR review process has started for request **${REQUEST_ID}**" "🚀"
        ;;
    "completed")
        send_teams_notification "✅ Automated PR review has been completed for request **${REQUEST_ID}**\n\nThe pull request has been analyzed and is ready for manual review." "✅"
        ;;
    "approved")
        send_teams_notification "👍 Pull request for request **${REQUEST_ID}** has been approved and merged!" "🎉"
        ;;
    "failed")
        send_teams_notification "❌ Automated PR review failed for request **${REQUEST_ID}**\n\nPlease check the GitHub Actions logs for details." "❌"
        ;;
    "status"|*)
        send_teams_notification "ℹ️ Status update for request **${REQUEST_ID}**\n\nThe pull request review is in progress." "ℹ️"
        ;;
esac

echo ""
echo "Notification sent for request: $REQUEST_ID"
