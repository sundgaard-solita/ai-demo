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

### 1. Main Workflow (`on_issue_created.yml`)
This workflow attempts to use the GitHub Copilot Models API:
- Triggers automatically on issue creation (`issues.opened` event)
- Uses the GitHub Copilot Models API endpoint: `/orgs/{org}/copilot/models/{model}/inference`
- Requires `issues: write`, `contents: read`, and `models: read` permissions
- **Note:** This requires GitHub Copilot access for the organization

**Known Issue:** If you see a 404 error, it means:
- GitHub Copilot Models may not be enabled for your organization
- The repository may not have access to Copilot Models  
- Contact your GitHub organization administrator to enable GitHub Copilot

### 2. Simple Fallback Workflow (`process_issue_simple.yml`)
A manual workflow that doesn't require Copilot:
- Runs manually via workflow_dispatch
- Extracts and formats Teams messages from JSON
- Provides basic formatting without AI processing
- Use this as a fallback if Copilot Models API is not available

To use the simple workflow:
1. Go to Actions → Process Issue - Simple Fallback
2. Click "Run workflow"
3. Enter the issue number
4. The workflow will reformat the issue content

### 3. Test Workflow (`test_models_api.yml`)  
A diagnostic workflow to test Copilot Models API access:
- Run manually to check if the API is accessible
- Helps diagnose 404 errors
- Useful for troubleshooting organizational access

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
