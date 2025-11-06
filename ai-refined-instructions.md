# AI-Refined Instructions for Automated Issue Processing

## Purpose
This file provides refined and enhanced instructions for AI agents processing Teams messages and GitHub issues for Solita Denmark.

---

## Core Responsibilities

### 1. Message Processing
- **Input:** Teams messages (JSON, XML, YAML, or plain text)
- **Output:** Clean, human-readable markdown documentation
- **Goal:** Convert raw data into actionable information

### 2. Request Tracking
- Create a subfolder under `requests/` using the `request-id` from the message headers
- Store all related documentation and scripts in this folder
- Maintain traceability from Teams message to GitHub issue to implementation

### 3. Documentation Structure

Each request folder should contain:

1. **README.md** - Main request summary
   - Sender information
   - Message content (with translation if needed)
   - Request metadata
   - Classification and analysis
   - Compliance notes

2. **action-items.md** - Actionable tasks
   - List of specific actions required
   - Priority and assignee recommendations
   - Estimated time for each action
   - Manual vs. automated action classification

3. **raw-message.json** - Original message data
   - Preserve the complete original Teams message
   - Useful for debugging and audit trails

4. **IaC Scripts** (when applicable)
   - Azure CLI scripts for resource provisioning
   - PowerShell scripts for Azure DevOps
   - GitHub CLI scripts for repository management
   - Terraform or Bicep templates if preferred

5. **no-iac-required.md** (when applicable)
   - Explanation of why IaC is not needed
   - Alternative recommended actions

---

## Message Classification

### Type 1: Infrastructure Changes
**Characteristics:**
- Requests to create/modify Azure resources
- Add/remove users from teams or subscriptions
- Update permissions or access controls

**Required Actions:**
- Generate IaC scripts
- Document security implications
- Create rollback procedures

**Examples:**
- "Add user X to subscription Y"
- "Create a new resource group for project Z"
- "Grant contributor access to user A"

### Type 2: GitHub/Azure DevOps Tasks
**Characteristics:**
- Repository management
- Pipeline configuration
- CI/CD updates

**Required Actions:**
- Create automation scripts using gh CLI or az devops CLI
- Document workflow changes
- Test scripts in a safe environment

**Examples:**
- "Create a new repository for project X"
- "Update pipeline to include security scanning"
- "Add branch protection rules"

### Type 3: Informational/Notifications
**Characteristics:**
- Status updates
- Reminders
- General announcements

**Required Actions:**
- Document the notification
- Identify any manual actions needed
- No automation or IaC required

**Examples:**
- "PR is ready for review"
- "Deployment completed successfully"
- "Team meeting at 2 PM"

### Type 4: Task Assignments
**Characteristics:**
- Direct action requests
- Task delegation
- Work assignments

**Required Actions:**
- Create detailed action items
- Suggest automation where possible
- Track completion status

**Examples:**
- "Create documentation for feature X"
- "Review security alerts in repository Y"
- "Update README with installation instructions"

---

## Security and Compliance

### ISO-27001 Requirements
- Use least privilege principle for all access grants
- Document security implications of any changes
- Ensure proper access controls are maintained
- Maintain audit trails through git history

### Placeholder Handling
When credentials or sensitive information are needed but not provided:
- Use clear placeholder names: `{{PAT_TOKEN}}`, `{{TENANT_ID}}`, `{{SUBSCRIPTION_ID}}`
- Document what credentials are needed in README.md
- Never hardcode credentials in scripts
- Suggest using GitHub Secrets or Azure Key Vault

### Code Review
Before generating scripts:
- Verify commands are safe and reversible
- Include error handling
- Add comments explaining each step
- Test in non-production environments when possible

---

## Best Practices

### Documentation
- Use clear, concise language
- Include translations for non-English messages (e.g., Danish to English)
- Provide context about Solita Denmark's environment
- Link to relevant Teams messages and resources

### Automation
- Prefer CLI tools (az, gh, git) over manual processes
- Generate idempotent scripts (safe to run multiple times)
- Include validation steps before making changes
- Provide rollback instructions

### Organization
- Keep request folders self-contained
- Use consistent naming conventions
- Update main README.md when adding new request patterns
- Maintain a changelog of processed requests

---

## Tools and Services

### Azure
- **Cloud Platform:** Azure (preferred)
- **CLI Tool:** `az` (Azure CLI)
- **Authentication:** Azure AD / Entra ID
- **Tenant:** Solita Denmark (domain: @solita.dk)

### GitHub
- **Version Control:** GitHub
- **CLI Tool:** `gh` (GitHub CLI)
- **Automation:** GitHub Actions
- **Security:** Dependabot, CodeQL, secret scanning

### Microsoft Teams
- **Communication:** Teams channels
- **Webhooks:** For issue creation from messages
- **Integration:** Microsoft Graph API

### Azure DevOps
- **Project Management:** Boards, Work Items
- **CI/CD:** Pipelines
- **CLI Tool:** `az devops` extension

---

## Workflow

1. **Receive Message:** Teams message creates GitHub issue
2. **Parse Data:** Extract sender, content, request-id, timestamp
3. **Classify Request:** Determine type (infrastructure, task, notification, etc.)
4. **Create Folder:** `requests/{{request-id}}/`
5. **Generate Documentation:** README, action-items, raw-message
6. **Create Scripts:** IaC or automation scripts (if applicable)
7. **Execute:** Run scripts if possible, or document manual steps
8. **Verify:** Check results, update documentation
9. **Complete:** Mark action items as done

---

## Future Enhancements

### Ideas for Improvement
1. **Automated Script Execution:** Run generated scripts automatically (with approval)
2. **Status Tracking:** Update Teams messages with progress
3. **Template Library:** Common IaC patterns for frequent requests
4. **Integration Testing:** Validate scripts before commit
5. **Metrics Dashboard:** Track request processing time and success rate

### Refinement Suggestions
- Add support for multi-language messages (Danish, Swedish, Norwegian)
- Integrate with Solita's specific Azure subscriptions by name
- Create templates for common request types
- Add validation for Teams message structure

---

## Contacts and Resources

- **Domain:** @solita.dk
- **Repository:** sundgaard-solita/ai-demo
- **Teams Tenant:** 635aa01e-f19d-49ec-8aed-4b2e4312a627
- **Team ID:** 45500773-64be-4e45-9aeb-0922cdb2f616

---

*This file should be updated with lessons learned from each request processing cycle.*
