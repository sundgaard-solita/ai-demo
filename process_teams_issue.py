#!/usr/bin/env python3
"""
Process Teams message issues and convert them to clean, readable format.
This script extracts information from raw Teams webhook JSON and formats it nicely.
"""

import json
import sys
import os
from datetime import datetime


def extract_teams_message(raw_json_str):
    """
    Extract meaningful information from Teams message JSON.
    
    Args:
        raw_json_str: Raw JSON string from Teams webhook. Expected structure:
            [{"body": {"from": {"user": {"displayName": str}}, 
                      "body": {"plainTextContent": str, "content": str},
                      "createdDateTime": str,
                      "webUrl": str}}]
    
    Returns:
        dict with keys: sender, date, plain_text, html_content, message_link
        or None if parsing fails
    """
    try:
        # Parse the JSON array
        data = json.loads(raw_json_str)
        
        # Handle both array and single object
        if isinstance(data, list) and len(data) > 0:
            data = data[0]
        
        # Extract the body content
        if 'body' in data and isinstance(data['body'], dict):
            body = data['body'].get('body', {})
            if isinstance(body, dict):
                plain_text = body.get('plainTextContent', '')
                html_content = body.get('content', '')
                
                # Extract sender information
                from_info = data['body'].get('from', {})
                user_info = from_info.get('user', {})
                sender_name = user_info.get('displayName', 'Unknown')
                
                # Extract timestamp
                created_dt = data['body'].get('createdDateTime', '')
                if created_dt:
                    try:
                        dt = datetime.fromisoformat(created_dt.replace('Z', '+00:00'))
                        formatted_date = dt.strftime('%B %d, %Y at %H:%M:%S UTC')
                    except:
                        formatted_date = created_dt
                else:
                    formatted_date = 'Unknown'
                
                # Extract message link
                message_link = data['body'].get('webUrl', '')
                
                return {
                    'sender': sender_name,
                    'date': formatted_date,
                    'plain_text': plain_text,
                    'html_content': html_content,
                    'message_link': message_link
                }
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        return None
    except (KeyError, TypeError, AttributeError) as e:
        print(f"Error extracting Teams message fields: {e}", file=sys.stderr)
        return None
    
    return None


def generate_title(message_info):
    """Generate a clean issue title from the message."""
    if not message_info:
        return "Teams Message"
    
    sender = message_info.get('sender', 'Unknown')
    plain_text = message_info.get('plain_text', '').strip()
    
    # Create a short title from the message
    if plain_text:
        # Truncate to first 50 chars if too long
        title_text = plain_text[:50]
        if len(plain_text) > 50:
            title_text += '...'
        return f"Teams Message: {title_text} - {sender}"
    else:
        return f"Teams Message - {sender}"


def generate_description(message_info):
    """Generate a markdown description from the message."""
    if not message_info:
        return "Could not parse Teams message content."
    
    sender = message_info.get('sender', 'Unknown')
    date = message_info.get('date', 'Unknown')
    plain_text = message_info.get('plain_text', '').strip()
    message_link = message_info.get('message_link', '')
    
    # Build markdown description
    description = f"""## Summary
Message from {sender}

## Message Details

**From**: {sender}  
**Date**: {date}  
**Channel**: Teams Channel (Solita Denmark)

### Original Message
> {plain_text}
"""
    
    # Add message link if available
    if message_link:
        description += f"\n[View in Teams]({message_link})\n"
    
    # Add action items section if the message seems actionable
    actionable_keywords = ['add', 'create', 'update', 'fix', 'review', 'check', 'pr', 'pull request']
    if any(keyword in plain_text.lower() for keyword in actionable_keywords):
        description += """
## Action Items
- [ ] Review and respond to the message
- [ ] Complete any requested actions

"""
    
    description += """---
*This issue was automatically created from a Microsoft Teams message via webhook integration.*
"""
    
    return description


def main():
    """Main function to process issue content."""
    if len(sys.argv) < 2:
        print("Usage: process_teams_issue.py '<raw_issue_body>'", file=sys.stderr)
        sys.exit(1)
    
    raw_body = sys.argv[1]
    
    # Try to detect if this is a Teams message JSON by attempting to parse it
    try:
        # Try parsing as JSON first
        test_parse = json.loads(raw_body)
        # Check if it has Teams message structure
        if not isinstance(test_parse, (list, dict)):
            raise ValueError("Not a Teams message structure")
    except (json.JSONDecodeError, ValueError):
        # Not JSON or not Teams message format
        print("Issue body doesn't appear to be Teams JSON format.", file=sys.stderr)
        print(json.dumps({
            'title': None,
            'description': None,
            'is_teams_message': False
        }))
        sys.exit(0)
    
    # Extract information
    message_info = extract_teams_message(raw_body)
    
    if not message_info:
        print("Could not parse Teams message format.", file=sys.stderr)
        print(json.dumps({
            'title': None,
            'description': None,
            'is_teams_message': True,
            'parse_error': True
        }))
        sys.exit(0)
    
    # Generate formatted output
    title = generate_title(message_info)
    description = generate_description(message_info)
    
    # Output as JSON for the workflow to consume
    result = {
        'title': title,
        'description': description,
        'is_teams_message': True,
        'parse_error': False
    }
    
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
