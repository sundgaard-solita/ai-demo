#!/usr/bin/env python3
"""
Process Teams messages from GitHub issues.
Extracts Teams message JSON and converts it to clean, human-readable format.
"""

import json
import sys
from typing import Dict, Any, Optional


def extract_teams_message(raw_content: str) -> Optional[Dict[str, Any]]:
    """
    Extract Teams message data from raw JSON content.
    
    Args:
        raw_content: Raw issue body content that may contain Teams message JSON
        
    Returns:
        Dict with extracted message data or None if not a Teams message
    """
    try:
        # Try to parse as JSON
        data = json.loads(raw_content)
        
        # Check if it's a list (Teams webhook format)
        if isinstance(data, list) and len(data) > 0:
            item = data[0]
            
            # Check if it has Teams message structure (HTTP response wrapper)
            if 'body' in item and isinstance(item['body'], dict):
                teams_message = item['body']
                
                # The actual message body is nested inside
                message_body = teams_message.get('body', {})
                
                # Extract key information
                message_data = {
                    'plain_text': message_body.get('plainTextContent', ''),
                    'html_content': message_body.get('content', ''),
                    'message_id': teams_message.get('id', ''),
                    'created_at': teams_message.get('createdDateTime', ''),
                    'from_user': None,
                    'message_link': teams_message.get('messageLink', '')
                }
                
                # Extract sender information
                if 'from' in teams_message and teams_message['from']:
                    user_info = teams_message['from'].get('user', {})
                    message_data['from_user'] = user_info.get('displayName', '')
                
                return message_data
                
        return None
        
    except (json.JSONDecodeError, KeyError, TypeError):
        return None


def format_as_markdown(message_data: Dict[str, Any]) -> tuple[str, str]:
    """
    Format Teams message data as clean markdown.
    
    Args:
        message_data: Extracted Teams message data
        
    Returns:
        Tuple of (title, description) in markdown format
    """
    plain_text = message_data.get('plain_text', '').strip()
    from_user = message_data.get('from_user', 'Unknown')
    created_at = message_data.get('created_at', '')
    message_id = message_data.get('message_id', '')
    message_link = message_data.get('message_link', '')
    
    # Create a title from the message content
    # Limit to first sentence or 60 characters
    title = plain_text
    if len(title) > 60:
        title = title[:57] + '...'
    elif '.' in title:
        title = title.split('.')[0]
    
    # If title is empty, use a default
    if not title:
        title = "Teams Message"
    
    # Format the description
    description = f"""## Teams Message

**From**: {from_user}  
**Date**: {created_at}  
**Message**: {plain_text}
"""
    
    # Add message link if available
    if message_link:
        description += f"\n[View in Teams]({message_link})"
    
    # Add metadata footer
    if message_id:
        description += f"\n\n---\n*Message ID: {message_id}*"
    
    return title, description


def main():
    """Main entry point for processing Teams messages."""
    if len(sys.argv) < 2:
        print("Usage: python process_teams_message.py <issue_body>")
        sys.exit(1)
    
    raw_content = sys.argv[1]
    
    # Try to extract Teams message
    message_data = extract_teams_message(raw_content)
    
    if message_data:
        title, description = format_as_markdown(message_data)
        
        # Output as JSON for easy parsing in workflow
        result = {
            'is_teams_message': True,
            'title': title,
            'description': description,
            'plain_text': message_data.get('plain_text', '')
        }
        print(json.dumps(result, indent=2))
    else:
        # Not a Teams message
        result = {
            'is_teams_message': False,
            'message': 'Content does not appear to be a Teams message'
        }
        print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
