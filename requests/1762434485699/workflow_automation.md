# Workflow Automation Documentation for Request 1762434485699

## Overview
This document describes the automation workflow for processing Microsoft Teams messages into GitHub issues.

## Process Flow

1. **Input Reception**
   - Teams message posted via webhook to GitHub issue
   - Raw JSON stored in `raw_input.json`

2. **Message Processing**
   - Extract sender information
   - Extract timestamp
   - Extract message content
   - Translate if needed (Danish to English)

3. **Issue Formatting**
   - Create descriptive title
   - Format message in markdown
   - Extract action items
   - Add metadata footer

4. **Output Storage**
   - Structured JSON: `processed_data.json`
   - Formatted markdown: `README.md`
   - Update script: `update_issue.sh`

## Automation Options

### Option 1: GitHub Actions Workflow
Use the existing `on_issue_created.yml` workflow with GitHub Copilot Models API.

### Option 2: Simple Processing Script
Use PowerShell or Bash to:
1. Parse the Teams JSON
2. Extract relevant fields
3. Format output
4. Update issue via GitHub CLI

### Option 3: Azure Function/Logic App
For advanced scenarios:
- Receive Teams webhook directly
- Process message
- Create formatted GitHub issue
- No need for intermediate JSON issue

## IaC Considerations

### Azure Resources (if needed)
```hcl
# Terraform example for Azure Function
resource "azurerm_function_app" "teams_processor" {
  name                       = "teams-to-github-processor"
  location                   = "westeurope"
  resource_group_name        = azurerm_resource_group.main.name
  app_service_plan_id        = azurerm_app_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  
  app_settings = {
    "GITHUB_TOKEN" = var.github_token
    "GITHUB_REPO"  = "sundgaard-solita/ai-demo"
  }
}
```

### GitHub Secrets Required
- `PAT_GITHUB` or `GH_TOKEN`: Personal Access Token with `repo` and `issues` permissions
- `TEAMS_WEBHOOK_URL`: Optional, for posting back to Teams

## Security Considerations

✅ **Implemented:**
- Input validation
- Structured data storage
- Read-only raw input preservation

⚠️ **Recommended:**
- Sanitize user input before processing
- Validate webhook signatures from Teams
- Use least-privilege tokens
- Audit log all processing actions
- Implement rate limiting

## Compliance Notes

- **ISO-27001**: All data processing follows information security standards
- **Data Privacy**: Personal identifiers (user IDs) are preserved but not exposed unnecessarily
- **Audit Trail**: Complete chain from raw input → processing → output
