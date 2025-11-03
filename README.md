# AI Demo - Automated Issue Processing

This repository contains GitHub Copilot automation tools for Solita Denmark.

## Features

### Automated Issue Processing from Teams Messages

When a new issue is created in this repository, a GitHub Actions workflow automatically processes the content.

**What it does:**
- Detects Microsoft Teams message JSON format
- Extracts the plain text message, sender name, and timestamp
- Reformats the issue with a clear title and structured description
- Preserves the original message metadata

**How it works:**
1. When an issue is created (e.g., from a Teams webhook), the `process_teams_issue.yml` workflow triggers
2. The workflow detects if the issue body contains Teams message JSON
3. If detected, it extracts the message details and updates the issue with:
   - A clean, descriptive title (from the message content)
   - Well-formatted markdown description with sender and timestamp
   - The original message content in a clear summary section

**Example:**

**Before** (raw Teams message JSON):
```json
[{"body":{"body":{"plainTextContent":"test 789"},"from":{"user":{"displayName":"Michael Ringholm Sundgaard"}},"createdDateTime":"2025-11-02T16:35:47.503Z"}}]
```

**After** (processed issue):
- **Title:** test 789
- **Description:** 
  ```markdown
  ## Summary
  test 789

  ## Message Details
  **From:** Michael Ringholm Sundgaard
  **Date:** 2025-11-02T16:35:47.503Z
  
  ---
  *This issue was automatically created from a Microsoft Teams message.*
  ```

## Workflow Configuration

The repository contains multiple workflow options:

### 1. Automated Teams Issue Processing (`process_teams_issue.yml`) ⭐ Recommended
This is the **primary workflow** for automatic issue processing:
- **Triggers automatically** on issue creation (`issues.opened` event)
- Detects Microsoft Teams message JSON format
- Extracts message content, sender name, and timestamp
- Reformats the issue with a clear title and well-structured description
- **No AI/Copilot required** - works with static parsing
- Skips processing for regular (non-Teams) issues

**What it does:**
When you create an issue containing Teams message JSON, it automatically:
1. Extracts the plain text message content
2. Identifies the sender and timestamp
3. Updates the issue with a clear title (from message content)
4. Formats the description with a summary and metadata

**Example:**
```json
[{"body":{"body":{"plainTextContent":"test 789"},"from":{"user":{"displayName":"Michael"}},"createdDateTime":"2025-11-02T16:35:47.503Z"}}]
```
Becomes:
- **Title:** test 789
- **Description:** Formatted markdown with sender info and timestamp

### 2. AI-Powered Workflow (`on_issue_created.yml`)
This workflow attempts to use the GitHub Copilot Models API:
- Triggers automatically on issue creation (`issues.opened` event)
- Uses the GitHub Copilot Models API endpoint: `/orgs/{org}/copilot/models/{model}/inference`
- Requires `issues: write`, `contents: read`, and `models: read` permissions
- **Note:** This requires GitHub Copilot access for the organization

**Known Issue:** If you see a 404 error, it means:
- GitHub Copilot Models may not be enabled for your organization
- The repository may not have access to Copilot Models  
- Contact your GitHub organization administrator to enable GitHub Copilot

### 3. Simple Fallback Workflow (`process_issue_simple.yml`)
A manual workflow that doesn't require Copilot:
- Runs manually via workflow_dispatch
- Extracts and formats Teams messages from JSON
- Provides basic formatting without AI processing
- Use this for reprocessing existing issues

To use the simple workflow:
1. Go to Actions → Process Issue - Simple Fallback
2. Click "Run workflow"
3. Enter the issue number
4. The workflow will reformat the issue content

### 4. Test Workflow (`test_models_api.yml`)  
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

## Important Notes

### Multiple Workflows on Issue Creation
Currently, **two workflows** trigger automatically when a new issue is created:
1. `process_teams_issue.yml` - Static Teams message processing (recommended)
2. `on_issue_created.yml` - AI-powered processing using Copilot Models API

Both workflows will attempt to update the same issue. You may want to:
- **Option 1 (Recommended):** Disable `on_issue_created.yml` if you don't have Copilot Models API access or prefer static processing
- **Option 2:** Keep both and let whichever completes first update the issue
- **Option 3:** Modify one workflow to check if the issue has already been processed

To disable a workflow, rename it with `.disabled` extension or remove the `on: issues: types: [opened]` trigger.

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
