# Request: Add Michael Ringholm Sundgaard (mrs) to RIT2

## Request Information

- **Request ID**: 1762259868977
- **Requested by**: Michael Ringholm Sundgaard
- **Request date**: 2025-11-04T12:37:48.977Z
- **Status**: Pending
- **Priority**: Normal

## Summary

Request to add user Michael Ringholm Sundgaard (mrs) to RIT2 team, resource group, or project.

## Details

### User Information
- **Display Name**: Michael Ringholm Sundgaard
- **User ID**: 81330d43-ae3b-4bb1-b698-4adacf0e5bca
- **Email**: (assumed) @solita.dk
- **Tenant**: 635aa01e-f19d-49ec-8aed-4b2e4312a627 (Solita Denmark)

### Target Resource
- **Name**: RIT2
- **Type**: To be determined (Azure Resource Group / Teams Team / GitHub Team / AD Group)

### Original Message
> add mrs to RIT2

**Source**: Microsoft Teams message from General channel
**Team ID**: 45500773-64be-4e45-9aeb-0922cdb2f616
**Channel ID**: 19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype

## Action Items

- [ ] Identify what "RIT2" refers to:
  - [ ] Azure AD Security Group
  - [ ] Microsoft Teams team
  - [ ] Azure Resource Group
  - [ ] GitHub team/repository
  - [ ] Azure DevOps project
  
- [ ] Verify user identity and permissions:
  - [ ] Confirm Michael Ringholm Sundgaard's current role
  - [ ] Verify authorization for RIT2 access
  - [ ] Check compliance with ISO-27001 requirements
  
- [ ] Add user to RIT2:
  - [ ] Add to Azure AD group (if applicable)
  - [ ] Add to Microsoft Teams team (if applicable)
  - [ ] Grant Azure resource group permissions (if applicable)
  - [ ] Add to GitHub team (if applicable)
  - [ ] Add to Azure DevOps project (if applicable)
  
- [ ] Confirm completion with requester
- [ ] Document the access grant

## Available Scripts

This directory contains Infrastructure as Code (IaC) scripts to automate the user addition process:

1. **azure-ad-group.sh** - Add user to Azure AD security group
2. **azure-rbac.sh** - Grant Azure RBAC permissions to resource group
3. **azure-devops.sh** - Add user to Azure DevOps project
4. **github-team.sh** - Add user to GitHub team
5. **teams-member.sh** - Add user to Microsoft Teams team

## Security & Compliance

- **ISO-27001 Compliance**: All operations follow least privilege principle
- **Access Control**: Verify proper authorization before execution
- **Audit Trail**: All operations are logged for compliance

## Execution Instructions

1. Review and confirm the target resource ("RIT2")
2. Verify authorization and approval
3. Update the placeholder values in the scripts
4. Execute the appropriate script(s)
5. Verify the operation completed successfully
6. Document the completion and notify the requester

## Notes

- All scripts use placeholder values (e.g., PAT_TOKEN, tenant_id)
- Update placeholders with actual values before execution
- Test in non-production environment first
- Follow Solita Denmark security policies
