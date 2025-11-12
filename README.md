# AI Demo - Automated Issue Processing

This repository contains GitHub Copilot automation tools for Solita Denmark.

## Features

### Automated Issue Processing from Teams Messages

When a new issue is created in this repository, a GitHub Actions workflow automatically processes the content using the GitHub Models API.

**What it does:**
- Converts rough input (JSON, XML, YAML, or plain text from MS Teams) into clean, human-readable markdown
- Extracts a clear, descriptive title
- Creates a well-formatted description
- Identifies and lists action items

**How it works:**
1. When an issue is created (e.g., from a Teams webhook), the workflow triggers
2. The GitHub Models API processes the issue body using AI (GPT-4o model)
3. The issue is automatically updated with:
   - A clean, descriptive title
   - Well-formatted markdown description
   - Extracted action items (if any)

**Example:**

**Before** (raw Teams message JSON):
```json
[{"body":{"plainTextContent":"Allan wrote add mrs to BDK team"}}]
```

**After** (processed issue):
- **Title:** Add MRS to BDK team
- **Description:** Well-formatted markdown with context and details
- **Action Items:** 
  - Add MRS to the BDK team
  - Verify team permissions
  - Notify requester

## Workflow Configuration

The repository contains multiple workflow options:

### 1. Teams Message Processor (`process_teams_issue.yml`) - **RECOMMENDED**
This is the main workflow for processing Teams messages:
- Triggers automatically on issue creation (`issues.opened` event)
- Uses a Python script to parse Teams webhook JSON
- Extracts message content, sender, and timestamp
- Formats issues with clean titles and markdown descriptions
- Adds "teams-message" label for easy filtering
- **No external API dependencies** - works reliably out of the box
- Requires only `issues: write` and `contents: read` permissions

### 2. Copilot Assignment (`on_issue_created.yml`)
This workflow assigns GitHub Copilot to new issues:
- Triggers automatically on issue creation
- Assigns the issue to Copilot for AI-assisted processing
- Sends notifications to Teams when complete
- Requires `issues: write` permission

### 3. Advanced Copilot Models API (`on_issue_created_new.yml.disabled`) - DISABLED
A more advanced workflow using GitHub Copilot Models API:
- Currently disabled (requires organizational Copilot access)
- Uses AI to process and format issue content
- Can be enabled if your organization has Copilot Models API access
- See troubleshooting section below if you want to use this

**Known Issue:** If you see a 404 error, it means:
- GitHub Copilot Models may not be enabled for your organization
- The repository may not have access to Copilot Models  
- Contact your GitHub organization administrator to enable GitHub Copilot

### 4. Test Workflow (`copilot_hello.yml`)  
A diagnostic workflow to test Copilot API access:
- Run manually to check if the API is accessible
- Helps diagnose 404 errors
- Useful for troubleshooting organizational access

## How It Works

The `process_teams_issue.yml` workflow:

1. **Detects Teams Messages**: When an issue is created, checks if it contains Teams webhook JSON
2. **Extracts Information**: Parses the JSON to extract:
   - Sender name and information
   - Message timestamp
   - Plain text content
   - Teams message link
3. **Formats Output**: Creates a clean markdown description with:
   - Summary section
   - Message details (sender, date, channel)
   - Original message (quoted)
   - Link to view in Teams
   - Action items (if applicable)
4. **Updates Issue**: Automatically updates the issue title and body
5. **Adds Label**: Tags the issue with "teams-message" for easy filtering

## Processing Script

The `process_teams_issue.py` script handles the parsing and formatting:
- Takes raw issue body as input
- Detects if it's a Teams message JSON
- Extracts relevant fields
- Returns formatted title and description as JSON
- Can be run standalone for testing

**Example usage:**
```bash
python3 process_teams_issue.py '<raw_json_content>'
```


## Context

This automation is designed for IT employees at Solita Denmark, working with:
- Azure cloud services
- Microsoft Teams
- Azure DevOps
- GitHub

Security and ISO-27001 compliance are maintained with proper access controls and least privilege principles.

## Troubleshooting

### HTTP 404 Error - API Not Found

If the workflow fails with a 404 error when calling the Copilot Models API, try these steps:

1. **Check Organization Access**
   - Verify that GitHub Copilot is enabled for your organization
   - Contact your organization administrator if needed

2. **Verify Permissions**
   - Ensure the workflow has `models: read` permission (already configured)
   - Check that your organization has access to GitHub Models

3. **Use the Fallback Workflow**
   - Use `process_issue_simple.yml` as a temporary workaround
   - This workflow provides basic formatting without requiring Copilot access

4. **Test API Access**
   - Run the `test_models_api.yml` workflow manually
   - This will help diagnose if the API is accessible

### Alternative Solutions

If GitHub Copilot Models API is not available for your organization:
- Use the simple fallback workflow for basic Teams message formatting
- Consider using GitHub Copilot Chat to manually process issues
- Set up a custom webhook to an external AI service (requires additional configuration)

# Using alternative agent 
You can use any alternative or self hosted agent such as ollama.

``` sh
ollama pull phi3:mini
ollama serve
python3 reasoning_agent.py
# write a one-sentence summary of clean code principles
```

