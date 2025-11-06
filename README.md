# AI Demo - Automated Issue Processing

This repository contains GitHub Copilot automation tools for Solita Denmark.

## Features

### Automated Issue Processing from Teams Messages

When a new issue is created in this repository, a GitHub Actions workflow automatically detects and processes Teams message content.

**What it does:**
- Automatically detects Teams message JSON format from Microsoft Graph API
- Converts raw Teams message data into clean, human-readable markdown
- Extracts message sender, timestamp, and content
- Preserves link to original Teams message for reference
- Updates issue with descriptive title and formatted description

**How it works:**
1. When an issue is created (e.g., from a Teams webhook), the workflow triggers
2. A Python script (`process_teams_message.py`) analyzes the issue body
3. If Teams message JSON is detected, it extracts the key information
4. The issue is automatically updated with:
   - A clean, descriptive title (extracted from message content)
   - Well-formatted markdown description with sender info and timestamp
   - Link back to the original Teams message

**Example:**

**Before** (raw Teams message JSON from webhook):
```json
[{"statusCode":200,"body":{"id":"1762434074275","from":{"user":{"displayName":"Michael Ringholm Sundgaard"}},"body":{"plainTextContent":"PR ligger klar i GitHub."}}}]
```

**After** (processed issue):
- **Title:** PR ligger klar i GitHub
- **Description:**
  ```markdown
  ## Teams Message

  **From**: Michael Ringholm Sundgaard  
  **Date**: 2025-11-06T13:01:14.275Z  
  **Message**: PR ligger klar i GitHub.

  [View in Teams](https://teams.microsoft.com/...)

  ---
  *Message ID: 1762434074275*
  ```

## Workflow Configuration

The repository's main workflow processes Teams messages automatically:

### Main Workflow (`on_issue_created.yml`)
This workflow processes Teams messages and assigns issues:
- Triggers automatically on issue creation (`issues.opened` event)
- Detects Teams message JSON format using `process_teams_message.py`
- Extracts and formats message content automatically
- Updates issue title and description with clean, readable content
- Assigns Copilot agent to the issue (if credentials are configured)
- Sends notification back to Teams (if webhook is configured)
- Requires only `issues: write` and `contents: read` permissions

**Key features:**
- ✅ Works without GitHub Copilot Models API (no special organization access needed)
- ✅ Processes Teams messages in real-time as issues are created
- ✅ Preserves original message context and links
- ✅ Gracefully handles non-Teams content (leaves regular issues unchanged)

## Testing

The repository includes automated tests for Teams message processing:

```bash
# Run tests
python3 test_teams_processing.py
```

Tests verify:
- Correct extraction of Teams message content
- Proper formatting of sender, timestamp, and message
- Detection of non-Teams content

## Scripts

### `process_teams_message.py`
Python script that processes Teams webhook JSON:
- Extracts message content from Microsoft Graph API response format
- Parses sender information, timestamps, and message text
- Formats output as clean markdown
- Returns JSON with title, description, and metadata

**Usage:**
```bash
python3 process_teams_message.py "<teams_json>"
```

**Output format:**
```json
{
  "is_teams_message": true,
  "title": "Message title",
  "description": "Markdown formatted description",
  "plain_text": "Original message text"
}
```

## Additional Workflows

The repository also contains other workflow files for reference:

### `copilot_hello.yml`
A test workflow for verifying GitHub Copilot CLI integration:
- Runs manually via workflow_dispatch
- Tests Copilot agent connectivity and capabilities
- Useful for debugging Copilot access issues

### `on_issue_created_new.yml.disabled`
Alternative workflow using GitHub Models API (currently disabled):
- Example of using GitHub Copilot Models API for issue processing
- Requires organization-level Copilot access
- Can be enabled if preferred over the simpler script-based approach

## Context

This automation is designed for IT employees at Solita Denmark, working with:
- Azure cloud services
- Microsoft Teams
- Azure DevOps
- GitHub

Security and ISO-27001 compliance are maintained with proper access controls and least privilege principles.

## Troubleshooting

### Issue Not Processing

If an issue is not being processed automatically:

1. **Check Issue Format**
   - Verify the issue body contains Teams message JSON from Microsoft Graph API
   - The JSON should be in the format: `[{"statusCode":200,"body":{...}}]`
   - Use `python3 process_teams_message.py "<json>"` to test manually

2. **Check Workflow Run**
   - Go to Actions tab in GitHub
   - Look for the "Process and Assign Issue" workflow
   - Check the logs for any errors

3. **Verify Permissions**
   - Ensure the workflow has `issues: write` permission
   - Check that `GITHUB_TOKEN` has proper access

### Testing Locally

You can test the Teams message processing locally:

```bash
# Test with a sample Teams message
python3 process_teams_message.py "$(cat samples/sample-input1.jsonl)"

# Run automated tests
python3 test_teams_processing.py
```

## Using Alternative Agents

You can use any alternative or self-hosted agent such as Ollama:

```sh
ollama pull phi3:mini
ollama serve
python3 reasoning_agent.py
# write a one-sentence summary of clean code principles
```

