# Request: Add Michael Ringholm Sundgaard (mrs) to DR3

**Request ID:** e04a4d84-8860-4241-af5b-9599e7640dd4

## Summary

Request to add user access to DR3 resource/team.

## Details

- **Requester:** Michael Ringholm Sundgaard
- **User to Add:** mrs (Michael Ringholm Sundgaard)
- **Target:** DR3 (Team or Azure Resource Group)
- **Timestamp:** 2025-11-04T13:19:30.287Z
- **Organization:** Solita Denmark

## Original Message

"add mrs to DR3"

## Action Items

- [ ] Grant Michael Ringholm Sundgaard access to DR3 (team or Azure resource group)
- [ ] Verify appropriate permissions level based on role
- [ ] Confirm access has been granted
- [ ] Notify requester of completion

## Context

This request was received via Microsoft Teams channel integration. The user "mrs" refers to Michael Ringholm Sundgaard, and "DR3" likely refers to a team or Azure resource group at Solita Denmark.

## Security Considerations

- Apply least privilege principle when assigning permissions
- Verify user identity before granting access
- Ensure compliance with ISO-27001 requirements
- Document all permission changes for audit trail

## Implementation

See the IaC scripts in this directory:
- `azure-add-user-to-rg.ps1` - PowerShell script to add user to Azure Resource Group
- `azure-add-user-to-rg.sh` - Bash script alternative for Azure CLI
- `azure-devops-add-user.ps1` - PowerShell script to add user to Azure DevOps team (if applicable)

## Execution Notes

Replace the following placeholders before execution:
- `{TENANT_ID}` - Azure AD Tenant ID (tenant ID for Solita Denmark)
- `{SUBSCRIPTION_ID}` - Azure Subscription ID
- `{PROJECT_NAME}` - Azure DevOps project name (for Azure DevOps script)
- `{PAT_TOKEN}` - Personal Access Token with appropriate permissions (for Azure DevOps script)
- `{ROLE}` - Appropriate RBAC role (default: Contributor)

Note: The scripts are pre-configured with:
- Resource Group: DR3
- User Email: mrs@solita.dk (Michael Ringholm Sundgaard)
