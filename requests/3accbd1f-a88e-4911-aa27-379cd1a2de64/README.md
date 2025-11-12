# Add MRS User to RIT5 Team/Resource Group

## Request Details
- **Request ID**: 3accbd1f-a88e-4911-aa27-379cd1a2de64
- **Sender**: Michael Ringholm Sundgaard
- **User ID**: 81330d43-ae3b-4bb1-b698-4adacf0e5bca
- **Timestamp**: 2025-11-04T12:59:22.456Z
- **Message Content**: "add mrs to RIT5"
- **Tenant ID**: 635aa01e-f19d-49ec-8aed-4b2e4312a627

## Summary
Request to add user MRS to the RIT5 environment/team/resource group in Azure.

## Context
This request was submitted via Microsoft Teams channel and requires provisioning access to the RIT5 environment, which may be:
- An Azure Resource Group
- An Azure DevOps team
- A Microsoft Teams team
- An access control group

## Action Items

- [ ] **Identify RIT5 Environment**: Determine what RIT5 refers to (Resource Group, Team, Project)
- [ ] **Verify User Identity**: Confirm "MRS" user identity and email address
- [ ] **Check Existing Permissions**: Review current access levels for MRS in related systems
- [ ] **Assign Appropriate Role**: Add MRS to RIT5 with least-privilege access (Reader, Contributor, or custom role)
- [ ] **Update Documentation**: Record the access grant in the access control matrix
- [ ] **Notify Requester**: Confirm completion to Michael Ringholm Sundgaard
- [ ] **ISO-27001 Compliance**: Ensure access request is logged and approved per security policy

## Infrastructure as Code Scripts

This folder contains the following IaC scripts:

1. **azure-rbac-assignment.bicep** - Azure RBAC role assignment using Bicep
2. **azure-rbac-assignment.tf** - Azure RBAC role assignment using Terraform
3. **devops-team-membership.ps1** - Azure DevOps team member addition
4. **teams-membership.ps1** - Microsoft Teams member addition
5. **audit-log.md** - Audit trail and compliance documentation

## Usage Instructions

### Prerequisites
- Azure CLI installed and authenticated
- Terraform (if using .tf files) or Azure PowerShell
- Appropriate permissions to assign roles
- Azure DevOps PAT with required scopes
- Microsoft Teams PowerShell module

### Execution Steps

1. **Identify the user MRS**:
   ```bash
   # Get user object ID from Azure AD
   az ad user show --id "mrs@solita.dk" --query objectId -o tsv
   ```

2. **Deploy Azure RBAC (choose one)**:
   ```bash
   # Using Bicep
   az deployment group create \
     --resource-group RIT5 \
     --template-file azure-rbac-assignment.bicep \
     --parameters principalId="<USER_OBJECT_ID>" roleName="Contributor"
   
   # Using Terraform
   terraform init
   terraform plan -var="principal_id=<USER_OBJECT_ID>"
   terraform apply -var="principal_id=<USER_OBJECT_ID>"
   ```

3. **Add to Azure DevOps**:
   ```powershell
   .\devops-team-membership.ps1 `
     -Organization "solita" `
     -ProjectName "RIT5" `
     -TeamName "RIT5" `
     -UserEmail "mrs@solita.dk"
   ```

4. **Add to Microsoft Teams**:
   ```powershell
   .\teams-membership.ps1 `
     -TeamName "RIT5" `
     -UserPrincipalName "mrs@solita.dk" `
     -Role "Member"
   ```

## Security Best Practices Implemented

1. **Least Privilege**: Scripts default to "Contributor" role, not "Owner"
2. **Audit Trail**: All scripts generate audit logs for compliance
3. **Secure Credentials**: Scripts use environment variables and Azure Key Vault, never hardcoded secrets
4. **Validation**: Input validation on all parameters
5. **Error Handling**: Proper try-catch blocks with meaningful error messages
6. **ISO-27001 Compliance**: 
   - Access requests are logged
   - Approval workflow is documented
   - Audit trail is maintained
   - Change tracking is implemented

## Follow-up Actions
- Notify Michael Ringholm Sundgaard upon completion
- Update access control documentation
- Schedule access review in 90 days per security policy

---

**Status**: Ready for implementation after approval  
**Priority**: Normal  
**Estimated Time**: 15-30 minutes
