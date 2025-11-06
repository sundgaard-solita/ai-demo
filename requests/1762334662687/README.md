# Add Michael Ringholm Sundgaard (MRS) to DR Team/Resource Group

**Request ID**: 1762334662687  
**Created**: 2025-11-05T09:24:22.687Z  
**Requester**: Michael Ringholm Sundgaard  
**User ID**: 81330d43-ae3b-4bb1-b698-4adacf0e5bca  
**Email**: [User email]@solita.dk

## Summary

Grant Michael Ringholm Sundgaard (MRS) access to the DR (Denmark) team or Azure resource group.

## Request Details

- **User**: Michael Ringholm Sundgaard
- **User Initials**: MRS
- **Target Resource**: DR (Denmark team/resource group)
- **Environment**: Azure Cloud / Azure DevOps
- **Organization**: Solita Denmark

## Action Items

- [ ] Identify the specific "DR" resource (Azure Resource Group, DevOps Team, or Teams channel)
- [ ] Verify Michael Ringholm Sundgaard's account and current permissions
- [ ] Add MRS to the appropriate Azure AD group or resource group
- [ ] Grant necessary role assignments (e.g., Contributor, Reader, or custom role)
- [ ] Update Azure DevOps team membership if applicable
- [ ] Add to relevant Teams channels or distribution lists
- [ ] Verify access has been granted successfully
- [ ] Notify requester upon completion

## Scripts Provided

This request includes Infrastructure as Code (IaC) scripts to automate the access provisioning:

1. **add-to-azure-ad-group.ps1** - Adds user to Azure AD security group
2. **add-to-resource-group.ps1** - Grants RBAC permissions on Azure Resource Group
3. **add-to-devops-team.ps1** - Adds user to Azure DevOps team
4. **verify-access.ps1** - Verifies all permissions have been granted correctly

## Azure Resources

The following resources may need to be updated:

- **Azure AD Groups**: Denmark/DR team security groups
- **Azure Resource Groups**: DR or Denmark-related resource groups
- **Azure DevOps**: Team membership in Denmark/DR project
- **RBAC Roles**: Contributor, Reader, or custom role assignments
- **Teams Channels**: Denmark/DR Teams channel membership

## Execution Instructions

1. **Prepare required parameters** - All scripts require explicit parameter values:
   - User Information:
     - `$UserObjectId` - Azure AD Object ID: `81330d43-ae3b-4bb1-b698-4adacf0e5bca`
     - `$UserEmail` - User email address (for DevOps scripts)
   - Azure Configuration:
     - `$TenantId` - Your Azure tenant ID
     - `$SubscriptionId` - Target Azure subscription ID
     - `$ResourceGroupName` - Specific DR resource group name
   - Security Groups & Teams:
     - `$ADGroupName` - Azure AD group name for DR team
     - `$DevOpsOrg` - Azure DevOps organization name
     - `$ProjectName` - Azure DevOps project name
     - `$TeamName` - Azure DevOps team name
   - Authentication:
     - `$PAT` - Personal Access Token for Azure DevOps (keep secure!)

2. Ensure you have the required permissions:
   - Azure AD administrator or User administrator role
   - Owner or User Access Administrator role on the resource group
   - Azure DevOps project administrator

3. Run the scripts in order with required parameters:
   ```powershell
   # 1. Add to Azure AD group
   .\add-to-azure-ad-group.ps1 `
     -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" `
     -GroupName "DR-Team-Members" `
     -TenantId "<YOUR_TENANT_ID>"
   
   # 2. Add to Azure Resource Group
   .\add-to-resource-group.ps1 `
     -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" `
     -ResourceGroupName "DR-Resources" `
     -RoleName "Contributor" `
     -SubscriptionId "<YOUR_SUBSCRIPTION_ID>" `
     -TenantId "<YOUR_TENANT_ID>"
   
   # 3. Add to Azure DevOps team
   .\add-to-devops-team.ps1 `
     -UserEmail "user@solita.dk" `
     -Organization "solita-dk" `
     -ProjectName "DR-Project" `
     -TeamName "DR-Team" `
     -PAT "<YOUR_PAT_TOKEN>"
   
   # 4. Verify access
   .\verify-access.ps1 `
     -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" `
     -UserEmail "user@solita.dk" `
     -TenantId "<YOUR_TENANT_ID>" `
     -SubscriptionId "<YOUR_SUBSCRIPTION_ID>" `
     -ResourceGroupName "DR-Resources" `
     -ADGroupName "DR-Team-Members" `
     -DevOpsOrg "solita-dk" `
     -ProjectName "DR-Project" `
     -TeamName "DR-Team" `
     -PAT "<YOUR_PAT_TOKEN>"
   ```

## Security & Compliance

- **ISO 27001 Compliance**: All access follows least privilege principle
- **No Hard-coded Secrets**: All scripts require explicit parameters (no default values)
- **Secure Authentication**: Scripts use Azure AD authentication with proper validation
- **Access Review**: Access should be reviewed periodically
- **Audit Trail**: All changes are logged in Azure Activity Log
- **Authorization**: Scripts verify permissions before making changes
- **Error Handling**: Comprehensive error handling and validation in all scripts

## Notes

- Confirm with requester which specific "DR" resource they need access to
- Ensure compliance with organization's access control policies
- Document the permission level being granted
- All scripts use placeholder values that must be replaced with actual values before execution
