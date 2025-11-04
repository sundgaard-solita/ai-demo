# Quick Start Guide - Request 1762259868977

## Overview

This request is for adding **Michael Ringholm Sundgaard (mrs)** to **RIT2**, which could be an Azure Resource Group, Teams team, GitHub team, or Azure DevOps project.

## Request Details

- **Request ID**: 1762259868977
- **Requested By**: Michael Ringholm Sundgaard
- **Date**: 2025-11-04T12:37:48.977Z
- **Original Message**: "add mrs to RIT2"
- **Source**: Microsoft Teams message

## Quick Start

### Option 1: Interactive Menu (Recommended)

```bash
cd requests/1762259868977
./run.sh
```

This will display an interactive menu to help you:
1. Choose the type of resource RIT2 represents
2. Execute the appropriate script
3. Perform full provisioning across all platforms

### Option 2: Run Individual Scripts

First, configure your environment:

```bash
cd requests/1762259868977
source ./config.env

# Set your tokens (don't commit these!)
export AZURE_DEVOPS_PAT='your-azure-devops-pat'
export GITHUB_PAT='your-github-pat'
```

Then run the specific script you need:

```bash
# Add to Azure AD Security Group
./azure-ad-group.sh

# Grant Azure RBAC permissions
./azure-rbac.sh

# Add to Azure DevOps project
./azure-devops.sh

# Add to GitHub team
./github-team.sh

# Add to Microsoft Teams team
./teams-member.sh
```

## Prerequisites

Before running any scripts, ensure you have:

### Required Tools
- **Azure CLI** - For Azure operations
  ```bash
  # Install on Ubuntu
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ```

- **GitHub CLI** - For GitHub operations
  ```bash
  # Install on Ubuntu
  sudo apt install gh
  ```

### Required Permissions
- Azure AD admin rights (for Azure AD and Teams operations)
- Resource Group admin rights (for RBAC operations)
- Azure DevOps organization admin
- GitHub organization admin

### Authentication Tokens
Generate these tokens and set them as environment variables:

1. **Azure DevOps PAT**
   - Go to: https://dev.azure.com/{org}/_usersSettings/tokens
   - Scopes: Member Entitlement Management (Read & Write)
   - `export AZURE_DEVOPS_PAT='your-token'`

2. **GitHub PAT**
   - Go to: https://github.com/settings/tokens
   - Scopes: `admin:org`
   - `export GITHUB_PAT='your-token'`

## Configuration

All scripts read from environment variables or use defaults. Key configurations in `config.env`:

```bash
# User Info
USER_DISPLAY_NAME="Michael Ringholm Sundgaard"
USER_OBJECT_ID="81330d43-ae3b-4bb1-b698-4adacf0e5bca"
USER_EMAIL="michael.sundgaard@solita.dk"

# Azure
TENANT_ID="635aa01e-f19d-49ec-8aed-4b2e4312a627"
RESOURCE_GROUP="RIT2"

# GitHub
GITHUB_ORG="sundgaard-solita"
TEAM_SLUG="rit2"
GITHUB_USERNAME="sundgaard"

# Azure DevOps
AZURE_DEVOPS_ORG="solita-denmark"
PROJECT_NAME="RIT2"
```

Update the `PLACEHOLDER_*` values with actual values before running.

## What Each Script Does

### 1. `azure-ad-group.sh`
- Adds user to Azure AD security group named "RIT2"
- Validates user and group existence
- Checks for existing membership
- Logs operation for audit trail

### 2. `azure-rbac.sh`
- Grants Azure RBAC permissions to resource group
- Default role: Contributor
- Validates resource group exists
- Checks for existing role assignments

### 3. `azure-devops.sh`
- Adds user to Azure DevOps organization
- Grants access to project "RIT2"
- Default access level: Basic
- Lists available teams for manual team assignment

### 4. `github-team.sh`
- Adds user to GitHub team in organization
- Default role: member
- Validates organization and team access
- Shows current team members

### 5. `teams-member.sh`
- Adds user to Microsoft Teams team
- Uses Microsoft Graph API
- Default role: member
- Validates team existence

## Security & Compliance

All scripts follow security best practices:

- ✅ **Least Privilege**: Minimal necessary permissions
- ✅ **Audit Logging**: All operations logged to `audit-log.txt`
- ✅ **ISO-27001 Compliance**: Proper access controls
- ✅ **Token Security**: Tokens via environment variables, not hardcoded
- ✅ **Validation**: Checks existence before operations
- ✅ **Error Handling**: Graceful failures with clear messages

## Audit Log

All operations are logged to `audit-log.txt` in the request directory:

```bash
cat requests/1762259868977/audit-log.txt
```

Example log entry:
```
[2025-11-04T12:37:48Z] Added user 'Michael Ringholm Sundgaard' (81330d43-ae3b-4bb1-b698-4adacf0e5bca) to group 'RIT2' (group-id)
```

## Troubleshooting

### "Not logged in to Azure"
```bash
az login --tenant 635aa01e-f19d-49ec-8aed-4b2e4312a627
```

### "Group/Team not found"
Check the name in `config.env` and verify it exists in the respective platform.

### "PAT token not configured"
Set the required environment variable:
```bash
export AZURE_DEVOPS_PAT='your-token'
export GITHUB_PAT='your-token'
```

### "Permission denied"
Ensure you have admin rights on the target resource.

## Completion Checklist

After running the scripts:

- [ ] Verify user was added successfully
- [ ] Check audit log for confirmation
- [ ] Notify requester (Michael Ringholm Sundgaard)
- [ ] Update GitHub issue status
- [ ] Document any issues encountered
- [ ] Archive request for compliance

## Support

For questions or issues:
1. Check the audit log: `./audit-log.txt`
2. Review script output for error messages
3. Verify prerequisites and permissions
4. Contact IT support or security team if needed

## Next Steps

1. **Identify RIT2**: Determine what "RIT2" actually refers to
2. **Get Approval**: Ensure proper authorization for access
3. **Run Scripts**: Execute appropriate scripts
4. **Verify**: Confirm user has access
5. **Notify**: Inform requester of completion
6. **Close Issue**: Update GitHub issue and mark as complete
