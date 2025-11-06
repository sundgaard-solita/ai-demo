#!/usr/bin/env python3
"""
Teams Message Processor
Extracts and processes Teams messages from GitHub issues
"""

import json
import sys
from datetime import datetime
from pathlib import Path


def parse_teams_message(issue_body):
    """
    Parse a Teams message from the issue body.
    
    Args:
        issue_body: The raw issue body containing Teams message JSON
        
    Returns:
        dict: Parsed message data or None if parsing fails
    """
    try:
        # Try to parse as JSON array
        data = json.loads(issue_body)
        
        if isinstance(data, list) and len(data) > 0:
            message_data = data[0]
            
            # Extract body information
            body_data = message_data.get('body', {})
            
            return {
                'messageId': body_data.get('id'),
                'message': body_data.get('body', {}).get('plainTextContent', ''),
                'messageHtml': body_data.get('body', {}).get('content', ''),
                'sender': body_data.get('from', {}).get('user', {}).get('displayName', 'Unknown'),
                'senderId': body_data.get('from', {}).get('user', {}).get('id'),
                'tenantId': body_data.get('from', {}).get('user', {}).get('tenantId'),
                'createdDateTime': body_data.get('createdDateTime'),
                'teamId': body_data.get('channelIdentity', {}).get('teamId'),
                'channelId': body_data.get('channelIdentity', {}).get('channelId'),
                'messageLink': body_data.get('messageLink'),
                'webUrl': body_data.get('webUrl'),
                'importance': body_data.get('importance', 'normal'),
                'locale': body_data.get('locale', 'en-us'),
                'raw': message_data
            }
        
        return None
    except json.JSONDecodeError:
        return None


def create_request_structure(message_data, base_path='requests'):
    """
    Create directory structure and files for the request.
    
    Args:
        message_data: Parsed message data
        base_path: Base directory for requests (default: 'requests')
        
    Returns:
        Path: Path to the created request directory
    """
    message_id = message_data.get('messageId', 'unknown')
    request_dir = Path(base_path) / message_id
    request_dir.mkdir(parents=True, exist_ok=True)
    
    # Save raw message
    raw_file = request_dir / 'raw-message.json'
    with raw_file.open('w', encoding='utf-8') as f:
        json.dump(message_data['raw'], f, indent=2, ensure_ascii=False)
    
    # Save metadata
    metadata = {
        'requestId': message_id,
        'type': 'teams-message',
        'status': 'processed',
        'createdAt': message_data.get('createdDateTime'),
        'processedAt': datetime.utcnow().isoformat() + 'Z',
        'message': message_data.get('message'),
        'sender': {
            'name': message_data.get('sender'),
            'userId': message_data.get('senderId'),
            'tenantId': message_data.get('tenantId')
        },
        'teams': {
            'messageId': message_id,
            'teamId': message_data.get('teamId'),
            'channelId': message_data.get('channelId'),
            'messageLink': message_data.get('messageLink')
        }
    }
    
    metadata_file = request_dir / 'metadata.json'
    with metadata_file.open('w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    # Create README
    readme_content = f"""# Request: {message_id}

## Summary
{message_data.get('message', 'No message content')}

## Details
- **From**: {message_data.get('sender', 'Unknown')}
- **Sent**: {message_data.get('createdDateTime', 'Unknown')}
- **Message ID**: {message_id}
- **Importance**: {message_data.get('importance', 'normal')}

## Links
- [View in Teams]({message_data.get('messageLink', '#')})

## Action Items
- [ ] Review message content
- [ ] Take appropriate action
- [ ] Update status

---

_Generated at {datetime.utcnow().isoformat()}Z_
"""
    
    readme_file = request_dir / 'README.md'
    with readme_file.open('w', encoding='utf-8') as f:
        f.write(readme_content)
    
    return request_dir


def generate_issue_update(message_data):
    """
    Generate formatted title and body for issue update.
    
    Args:
        message_data: Parsed message data
        
    Returns:
        tuple: (title, body) for the issue
    """
    message = message_data.get('message', 'No message content')
    sender = message_data.get('sender', 'Unknown')
    created = message_data.get('createdDateTime', 'Unknown')
    message_id = message_data.get('messageId', 'Unknown')
    message_link = message_data.get('messageLink', '#')
    
    title = f"Teams Message: {message[:50]}... - from {sender}"
    if len(message) <= 50:
        title = f"Teams Message: {message} - from {sender}"
    
    body = f"""## Summary
Notification from Microsoft Teams

## Message
**"{message}"**

## Details
- **From**: {sender}
- **Sent**: {created}
- **Message ID**: {message_id}

## Action Required
Please review and take appropriate action based on the message content.

## Links
- [View original message in Teams]({message_link})

---

_This issue was automatically processed from a Microsoft Teams message._
"""
    
    return title, body


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python3 teams_message_processor.py <issue_body_json>")
        print("   or: python3 teams_message_processor.py --file <json_file>")
        sys.exit(1)
    
    # Read input
    if sys.argv[1] == '--file':
        if len(sys.argv) < 3:
            print("Error: --file requires a filename")
            sys.exit(1)
        with open(sys.argv[2], 'r', encoding='utf-8') as f:
            issue_body = f.read()
    else:
        issue_body = ' '.join(sys.argv[1:])
    
    # Parse message
    print("📥 Parsing Teams message...")
    message_data = parse_teams_message(issue_body)
    
    if not message_data:
        print("❌ Could not parse Teams message format")
        sys.exit(1)
    
    print(f"✅ Parsed message from {message_data.get('sender')}")
    print(f"   Message: {message_data.get('message')}")
    print(f"   ID: {message_data.get('messageId')}")
    
    # Create request structure
    print("\n📁 Creating request structure...")
    request_dir = create_request_structure(message_data)
    print(f"✅ Created: {request_dir}")
    
    # Generate issue update
    print("\n📝 Generated issue update:")
    title, body = generate_issue_update(message_data)
    print(f"   Title: {title}")
    print(f"\n   Body:\n{body}")
    
    print("\n✨ Processing complete!")
    print(f"\n💡 To update the GitHub issue, run:")
    print(f"   gh issue edit <issue_number> --title \"{title}\" --body \"$(cat <<'EOF'\n{body}\nEOF\n)\"")


if __name__ == '__main__':
    main()
