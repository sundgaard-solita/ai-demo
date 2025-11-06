#!/usr/bin/env python3
"""
Tests for Teams message processing script.
"""

import json
import subprocess
import sys


def test_teams_message_processing():
    """Test that Teams messages are correctly processed."""
    # Sample Teams message (same format as in samples/sample-input1.jsonl)
    teams_json = '''[{"statusCode":200,"body":{"id":"1762434074275","createdDateTime":"2025-11-06T13:01:14.275Z","from":{"user":{"displayName":"Michael Ringholm Sundgaard"}},"body":{"contentType":"html","content":"<p>PR ligger klar i GitHub.</p>","plainTextContent":"PR ligger klar i GitHub."},"messageLink":"https://teams.microsoft.com/l/message/test"}}]'''
    
    # Run the script
    result = subprocess.run(
        ['python3', 'process_teams_message.py', teams_json],
        capture_output=True,
        text=True,
        check=True
    )
    
    # Parse output
    output = json.loads(result.stdout)
    
    # Assertions
    assert output['is_teams_message'] is True, "Should detect Teams message"
    assert output['title'] == "PR ligger klar i GitHub", f"Unexpected title: {output['title']}"
    assert output['plain_text'] == "PR ligger klar i GitHub.", f"Unexpected plain text: {output['plain_text']}"
    assert 'Michael Ringholm Sundgaard' in output['description'], "Should include sender name"
    assert '2025-11-06T13:01:14.275Z' in output['description'], "Should include timestamp"
    
    print("✅ Test 1: Teams message processing - PASSED")


def test_non_teams_content():
    """Test that non-Teams content is correctly identified."""
    regular_text = "This is just a regular issue description"
    
    # Run the script
    result = subprocess.run(
        ['python3', 'process_teams_message.py', regular_text],
        capture_output=True,
        text=True,
        check=True
    )
    
    # Parse output
    output = json.loads(result.stdout)
    
    # Assertions
    assert output['is_teams_message'] is False, "Should not detect Teams message in regular text"
    
    print("✅ Test 2: Non-Teams content detection - PASSED")


def main():
    """Run all tests."""
    print("Running Teams message processing tests...\n")
    
    try:
        test_teams_message_processing()
        test_non_teams_content()
        
        print("\n🎉 All tests passed!")
        return 0
    except AssertionError as e:
        print(f"\n❌ Test failed: {e}")
        return 1
    except Exception as e:
        print(f"\n❌ Error running tests: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
