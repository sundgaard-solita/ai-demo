# Add User to Team - RIT5

## Summary
Request to add Michael Ringholm Sundgaard (MRS) to the RIT5 team.

## Details

- **Requester:** Michael Ringholm Sundgaard
- **User to Add:** Michael Ringholm Sundgaard (mrs)
- **Target Team:** RIT5
- **Request Date:** November 4, 2025 at 12:59 UTC
- **Request ID:** 1762261162456
- **Context:** Solita Denmark IT Operations

## Action Items

- [ ] Verify user identity: Michael Ringholm Sundgaard (Azure AD ID: `81330d43-ae3b-4bb1-b698-4adacf0e5bca`)
- [ ] Identify RIT5 team location (Azure DevOps, GitHub, or Azure AD Security Group)
- [ ] Add user to RIT5 team with appropriate permissions
- [ ] Verify team membership and access permissions
- [ ] Notify requester upon completion

## Security & Compliance

- ✅ Request follows least privilege principle
- ✅ ISO-27001 compliance maintained
- ✅ Audit trail via request ID: 1762261162456
- ✅ User authentication via Azure AD

## Scripts

The following IaC scripts are available in this directory to complete this request:

1. **azure-ad-add-user.ps1** - Add user to Azure AD security group
2. **azure-devops-add-user.sh** - Add user to Azure DevOps team
3. **github-add-user.sh** - Add user to GitHub team

Choose the appropriate script based on where the RIT5 team is configured.

## Next Steps

1. Confirm which platform RIT5 exists on (Azure AD / Azure DevOps / GitHub)
2. Execute the appropriate script from this directory
3. Verify access and permissions
4. Close this issue with confirmation
