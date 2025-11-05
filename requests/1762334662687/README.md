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

1. Review and update placeholder values in each script:
   - `$tenantId` - Your Azure tenant ID
   - `$subscriptionId` - Target Azure subscription ID
   - `$resourceGroupName` - Specific DR resource group name
   - `$adGroupName` - Azure AD group name
   - `$devOpsOrganization` - Azure DevOps organization name
   - `$projectName` - Azure DevOps project name
   - `$teamName` - Azure DevOps team name

2. Ensure you have the required permissions:
   - Azure AD administrator or User administrator role
   - Owner or User Access Administrator role on the resource group
   - Azure DevOps project administrator

3. Run the scripts in order:
   ```powershell
   # 1. Add to Azure AD group
   .\add-to-azure-ad-group.ps1
   
   # 2. Add to Azure Resource Group
   .\add-to-resource-group.ps1
   
   # 3. Add to Azure DevOps team
   .\add-to-devops-team.ps1
   
   # 4. Verify access
   .\verify-access.ps1
   ```

## Security & Compliance

- **ISO 27001 Compliance**: All access follows least privilege principle
- **Access Review**: Access should be reviewed periodically
- **Audit Trail**: All changes are logged in Azure Activity Log
- **Authentication**: Scripts use Azure AD authentication
- **Authorization**: Scripts verify permissions before making changes

## Notes

- Confirm with requester which specific "DR" resource they need access to
- Ensure compliance with organization's access control policies
- Document the permission level being granted
- All scripts use placeholder values that must be replaced with actual values before execution
