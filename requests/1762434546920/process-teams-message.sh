#!/bin/bash

# Teams Message Processor
# Extracts and processes Teams messages from GitHub issues
# Usage: ./process-teams-message.sh <issue_number>

set -e

ISSUE_NUMBER="$1"
REPO="sundgaard-solita/ai-demo"

if [ -z "$ISSUE_NUMBER" ]; then
    echo "Error: Issue number is required"
    echo "Usage: $0 <issue_number>"
    exit 1
fi

echo "📥 Processing Teams message from issue #$ISSUE_NUMBER..."

# Fetch issue content
ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json body,title,number)

# Extract the body
BODY=$(echo "$ISSUE_JSON" | jq -r '.body')

# Try to parse as JSON array (Teams message format)
if echo "$BODY" | jq -e '.[0].body.plainTextContent' > /dev/null 2>&1; then
    MESSAGE=$(echo "$BODY" | jq -r '.[0].body.plainTextContent')
    MESSAGE_ID=$(echo "$BODY" | jq -r '.[0].body.id // empty')
    SENDER=$(echo "$BODY" | jq -r '.[0].body.from.user.displayName // "Unknown"')
    CREATED=$(echo "$BODY" | jq -r '.[0].body.createdDateTime // empty')
    
    echo "✅ Successfully parsed Teams message:"
    echo "   Message: $MESSAGE"
    echo "   From: $SENDER"
    echo "   ID: $MESSAGE_ID"
    echo "   Created: $CREATED"
    
    # Create request directory
    if [ -n "$MESSAGE_ID" ]; then
        REQUEST_DIR="requests/$MESSAGE_ID"
        mkdir -p "$REQUEST_DIR"
        echo "📁 Created directory: $REQUEST_DIR"
        
        # Save raw JSON
        echo "$BODY" | jq '.' > "$REQUEST_DIR/raw-message.json"
        echo "💾 Saved raw message to $REQUEST_DIR/raw-message.json"
    fi
    
    # Generate suggested issue update
    NEW_TITLE="Teams Message: $MESSAGE - from $SENDER"
    NEW_BODY=$(cat <<EOF
## Summary
Notification from Microsoft Teams

## Message
**"$MESSAGE"**

## Details
- **From**: $SENDER
- **Sent**: $CREATED
- **Message ID**: $MESSAGE_ID

## Action Required
Please review and take appropriate action based on the message content.

---

_This issue was automatically processed from a Microsoft Teams message._
EOF
)
    
    echo ""
    echo "📝 Suggested issue update:"
    echo "   Title: $NEW_TITLE"
    echo ""
    echo "   Body:"
    echo "$NEW_BODY"
    echo ""
    
    # Ask for confirmation before updating
    read -p "Update issue #$ISSUE_NUMBER with this content? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Update the issue
        echo "$NEW_BODY" | gh issue edit "$ISSUE_NUMBER" \
            --repo "$REPO" \
            --title "$NEW_TITLE" \
            --body-file -
        echo "✅ Issue #$ISSUE_NUMBER updated successfully!"
    else
        echo "⏭️  Skipped issue update"
    fi
else
    echo "❌ Could not parse Teams message format from issue body"
    exit 1
fi

echo ""
echo "✨ Processing complete!"
