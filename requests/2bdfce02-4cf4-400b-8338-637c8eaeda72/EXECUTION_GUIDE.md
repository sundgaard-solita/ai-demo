# Execution Guide

This guide provides step-by-step instructions for executing the IaC scripts to grant access to Michael Ringholm Sundgaard (mrs) for BDK7.

## Prerequisites

Before running these scripts, ensure you have:

1. **Azure CLI** - Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. **GitHub CLI** - Install from https://cli.github.com/
3. **Appropriate Permissions** - You must have admin/owner rights to:
   - Azure subscription/resource group BDK7
   - Azure DevOps project/team BDK7
   - GitHub organization/repository BDK7

4. **Authentication Credentials**:
   - Azure credentials (will prompt for login if needed)
   - Azure DevOps PAT token with appropriate permissions
   - GitHub Personal Access Token with admin permissions

## Execution Order

Execute scripts in the following order based on what BDK7 represents:

### Option 1: If BDK7 is an Azure Subscription or Resource Group

```bash
# Navigate to the request folder
cd requests/2bdfce02-4cf4-400b-8338-637c8eaeda72

# Run the Azure RBAC script
./azure-rbac.sh
```

**Environment Variables** (optional):
```bash
export AZURE_TENANT_ID="635aa01e-f19d-49ec-8aed-4b2e4312a627"
export SUBSCRIPTION_NAME_OR_ID="BDK7"
export RESOURCE_GROUP_NAME="BDK7"
export AZURE_ROLE="Reader"  # or "Contributor", "Owner"
```

### Option 2: If BDK7 is an Azure DevOps Team

```bash
# Navigate to the request folder
cd requests/2bdfce02-4cf4-400b-8338-637c8eaeda72

# Set your PAT token
export AZURE_DEVOPS_PAT="your_pat_token_here"

# Run the Azure DevOps script
./azure-devops.sh
```

**Environment Variables** (optional):
```bash
export AZURE_DEVOPS_ORG="solita-denmark"
export AZURE_DEVOPS_PROJECT="BDK"
export AZURE_DEVOPS_TEAM="BDK7"
```

**Creating an Azure DevOps PAT Token**:
1. Go to https://dev.azure.com/solita-denmark/_usersSettings/tokens
2. Click "New Token"
3. Give it a name (e.g., "BDK7 Access Management")
4. Set expiration (recommended: 30 days)
5. Select scopes:
   - Project and Team: Read, write, & manage
   - Member Entitlement Management: Read & write
6. Create and copy the token

### Option 3: If BDK7 is a GitHub Organization or Repository

```bash
# Navigate to the request folder
cd requests/2bdfce02-4cf4-400b-8338-637c8eaeda72

# Run the GitHub access script
./github-access.sh
```

**Environment Variables** (optional):
```bash
export GITHUB_ORG="sundgaard-solita"
export GITHUB_REPO="BDK7"
export USER_GITHUB_USERNAME="mrs-github"  # Replace with actual GitHub username
export GITHUB_ROLE="read"  # or "write", "admin", "maintain", "triage"
export GITHUB_TOKEN="your_github_token_here"
```

**Creating a GitHub Personal Access Token**:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name (e.g., "BDK7 Access Management")
4. Set expiration (recommended: 30 days)
5. Select scopes:
   - `admin:org` (if managing organization)
   - `repo` (if managing repository)
6. Generate and copy the token

## Verification

After running each script, verify the access was granted:

### Azure RBAC Verification
```bash
az role assignment list --assignee mrs@solita.dk --scope <scope> -o table
```

### Azure DevOps Verification
```bash
az devops team list-member --team BDK7 --project BDK --query "value[?identity.uniqueName=='mrs@solita.dk']" -o table
```

### GitHub Verification
```bash
# For repository
gh api /repos/sundgaard-solita/BDK7/collaborators/mrs-github

# For organization
gh api /orgs/BDK7/members/mrs-github
```

## Rollback

If you need to remove the access granted:

### Remove Azure RBAC
```bash
az role assignment delete --assignee mrs@solita.dk --scope <scope>
```

### Remove from Azure DevOps Team
```bash
az devops team remove-member --team BDK7 --user mrs@solita.dk --project BDK
```

### Remove from GitHub
```bash
# For repository
gh api --method DELETE /repos/sundgaard-solita/BDK7/collaborators/mrs-github

# For organization
gh api --method DELETE /orgs/BDK7/members/mrs-github
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Ensure you're logged in: `az login`, `gh auth login`
   - Check token permissions and expiration
   - Verify your user has admin rights

2. **Resource Not Found**
   - Verify the exact name of subscription/resource group/team/repository
   - Check organization and project names
   - Use `az account list`, `az devops team list`, `gh repo list` to list resources

3. **Permission Denied**
   - Ensure your account has Owner/Admin role
   - For Azure: need Owner role on subscription/RG
   - For Azure DevOps: need Project Administrator permissions
   - For GitHub: need Organization Owner or Repository Admin

4. **User Not Found**
   - Verify email address is correct: mrs@solita.dk
   - For GitHub, ensure GitHub username is correct
   - Check that user account exists in Azure AD/GitHub

## Security Notes

- All tokens should be stored securely and never committed to Git
- Use environment variables or secure vaults (Azure Key Vault, GitHub Secrets)
- Rotate tokens regularly (recommended: every 30-90 days)
- Follow principle of least privilege - grant minimum necessary permissions
- Maintain audit logs of all access changes
- Remove access when no longer needed

## Notification

After successful execution, notify the requestor:
- **To:** Michael Ringholm Sundgaard (mrs@solita.dk)
- **Subject:** Access Granted to BDK7
- **Message:**
  ```
  Hi Michael,
  
  Your access to BDK7 has been granted as requested.
  
  Request ID: 2bdfce02-4cf4-400b-8338-637c8eaeda72
  Granted: [Date/Time]
  Scope: [Azure/Azure DevOps/GitHub]
  Permission Level: [Role]
  
  You should now be able to access BDK7 with the appropriate permissions.
  
  If you encounter any issues, please contact the IT team.
  
  Best regards,
  IT Operations Team
  ```

## Documentation

All changes are documented in this folder:
- `README.md` - Task description and context
- `azure-rbac.sh` - Azure subscription/RG access script
- `azure-devops.sh` - Azure DevOps team membership script
- `github-access.sh` - GitHub access script
- `EXECUTION_GUIDE.md` - This file

Git commit history provides audit trail of when scripts were created and any modifications made.
