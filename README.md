# AI Demo - Automated Issue Processing

This repository contains GitHub Copilot automation tools for Solita Denmark.

## Features

### Automated Issue Processing from Teams Messages

When a new issue is created in this repository, a GitHub Actions workflow automatically processes the content using GitHub Copilot Chat API.

**What it does:**
- Converts rough input (JSON, XML, YAML, or plain text from MS Teams) into clean, human-readable markdown
- Extracts a clear, descriptive title
- Creates a well-formatted description
- Identifies and lists action items

**How it works:**
1. When an issue is created (e.g., from a Teams webhook), the workflow triggers
2. The Copilot Chat API processes the issue body using AI
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

The workflow is defined in `.github/workflows/on_issue_created.yml` and:
- Triggers on issue creation (`issues.opened` event)
- Uses the GitHub Copilot Chat API (`/copilot/chat/completions`)
- Requires `issues: write` and `contents: read` permissions
- Automatically updates the issue with processed content

## Context

This automation is designed for IT employees at Solita Denmark, working with:
- Azure cloud services
- Microsoft Teams
- Azure DevOps
- GitHub

Security and ISO-27001 compliance are maintained with proper access controls and least privilege principles.
