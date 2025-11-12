# Testing the Teams Message Processor

This document explains how to test the Teams message processing functionality.

## Manual Testing

### 1. Test the Python Script Locally

You can test the processing script directly:

```bash
# Test with sample data
python3 process_teams_issue.py "$(cat samples/sample-input1.jsonl)"

# Test with custom JSON
python3 process_teams_issue.py '[{"body":{"from":{"user":{"displayName":"Test User"}},"body":{"plainTextContent":"Test message"},"createdDateTime":"2025-11-06T12:00:00Z","webUrl":"https://example.com"}}]'
```

### 2. Run the Test Suite

Run the automated tests:

```bash
python3 test_process_teams_issue.py
```

This will verify:
- Valid Teams messages are processed correctly
- Non-JSON input is handled gracefully
- Sample files are parsed properly

### 3. Test the GitHub Actions Workflow

To test the actual workflow in GitHub:

1. Create a new issue with raw Teams JSON:
   - Go to Issues → New Issue
   - Use a Teams message ID as the title (e.g., `1762434290614`)
   - Paste Teams webhook JSON in the body
   - Submit the issue

2. Watch the Actions tab:
   - Go to Actions → Process Teams Message Issues
   - Wait for the workflow to complete
   - Check the issue - it should be updated with formatted content

3. Verify the results:
   - Issue title should be descriptive (e.g., "Teams Message: ... - Sender Name")
   - Issue body should have formatted markdown
   - Issue should have the "teams-message" label

## Sample Teams Message JSON

Here's a minimal Teams message JSON for testing:

```json
[{
  "body": {
    "id": "1234567890",
    "messageType": "message",
    "createdDateTime": "2025-11-06T13:00:00Z",
    "from": {
      "user": {
        "displayName": "Test User"
      }
    },
    "body": {
      "plainTextContent": "This is a test message"
    },
    "webUrl": "https://teams.microsoft.com/l/message/test"
  }
}]
```

## Expected Output Format

The processor should generate:

### Title
```
Teams Message: This is a test message - Test User
```

### Description
```markdown
## Summary
Message from Test User

## Message Details

**From**: Test User  
**Date**: November 06, 2025 at 13:00:00 UTC  
**Channel**: Teams Channel (Solita Denmark)

### Original Message
> This is a test message

[View in Teams](https://teams.microsoft.com/l/message/test)

---
*This issue was automatically created from a Microsoft Teams message via webhook integration.*
```

## Troubleshooting

### Workflow Not Triggering

If the workflow doesn't run:
1. Check that `process_teams_issue.yml` exists in `.github/workflows/`
2. Verify the workflow is enabled in Settings → Actions
3. Check workflow permissions in Settings → Actions → General

### Parsing Errors

If the script fails to parse:
1. Verify the JSON is valid (use `jq` or a JSON validator)
2. Check that the JSON has the expected structure (see sample above)
3. Review the workflow logs in Actions tab for error messages

### Issue Not Updated

If the issue isn't updated:
1. Check that the workflow has `issues: write` permission
2. Verify `GITHUB_TOKEN` has proper scope
3. Look for error messages in the workflow logs
