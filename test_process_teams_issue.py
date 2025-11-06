#!/usr/bin/env python3
"""
Simple tests for process_teams_issue.py
"""

import json
import subprocess
import sys


def test_valid_teams_message():
    """Test processing a valid Teams message."""
    teams_json = '''[{"statusCode":200,"body":{"id":"1762434290614","messageType":"message","createdDateTime":"2025-11-06T13:04:50.614Z","from":{"user":{"displayName":"Michael Ringholm Sundgaard"}},"body":{"contentType":"html","content":"<p>PR ligger klar i GitHub.</p>","plainTextContent":"PR ligger klar i GitHub."},"webUrl":"https://teams.microsoft.com/l/message/test"}}]'''
    
    result = subprocess.run(
        ['python3', 'process_teams_issue.py', teams_json],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"❌ Test failed: process exited with code {result.returncode}")
        print(f"stderr: {result.stderr}")
        return False
    
    try:
        output = json.loads(result.stdout)
        
        # Verify expected fields
        assert output.get('is_teams_message') == True, "Should detect Teams message"
        assert output.get('parse_error') == False, "Should not have parse error"
        assert output.get('title') is not None, "Should have title"
        assert output.get('description') is not None, "Should have description"
        assert 'Michael Ringholm Sundgaard' in output.get('title', ''), "Title should include sender"
        assert 'PR ligger klar i GitHub' in output.get('description', ''), "Description should include message"
        
        print("✅ Test passed: valid Teams message")
        return True
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"❌ Test failed: {e}")
        print(f"stdout: {result.stdout}")
        return False


def test_non_json_input():
    """Test that non-JSON input is handled gracefully."""
    non_json = "This is just plain text, not JSON"
    
    result = subprocess.run(
        ['python3', 'process_teams_issue.py', non_json],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"❌ Test failed: process exited with code {result.returncode}")
        return False
    
    try:
        output = json.loads(result.stdout)
        
        # Verify it's detected as not a Teams message
        assert output.get('is_teams_message') == False, "Should not detect as Teams message"
        
        print("✅ Test passed: non-JSON input handled correctly")
        return True
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"❌ Test failed: {e}")
        print(f"stdout: {result.stdout}")
        return False


def test_sample_file():
    """Test with the sample file."""
    with open('samples/sample-input1.jsonl', 'r') as f:
        sample_data = f.read()
    
    result = subprocess.run(
        ['python3', 'process_teams_issue.py', sample_data],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"❌ Test failed: process exited with code {result.returncode}")
        print(f"stderr: {result.stderr}")
        return False
    
    try:
        output = json.loads(result.stdout)
        
        # Verify expected fields
        assert output.get('is_teams_message') == True, "Should detect Teams message"
        assert output.get('parse_error') == False, "Should not have parse error"
        assert 'Allan wrote add mrs to BDK team' in output.get('description', ''), "Should include message content"
        
        print("✅ Test passed: sample file processed correctly")
        return True
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"❌ Test failed: {e}")
        print(f"stdout: {result.stdout}")
        return False


def main():
    """Run all tests."""
    print("Running tests for process_teams_issue.py\n")
    
    tests = [
        test_valid_teams_message,
        test_non_json_input,
        test_sample_file
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} raised exception: {e}")
            failed += 1
        print()
    
    print(f"\n{'='*50}")
    print(f"Results: {passed} passed, {failed} failed")
    print(f"{'='*50}")
    
    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
