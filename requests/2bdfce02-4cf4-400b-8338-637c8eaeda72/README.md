# Add Michael Ringholm Sundgaard (mrs) to BDK7

## Summary
Grant access for Michael Ringholm Sundgaard to BDK7 (Azure subscription/resource group or Azure DevOps team).

## Request Details
- **Requested by:** Michael Ringholm Sundgaard (mrs@solita.dk)
- **Request date:** November 5, 2025, 10:43 AM UTC
- **Organization:** Solita Denmark
- **Request ID:** 2bdfce02-4cf4-400b-8338-637c8eaeda72
- **Teams Message ID:** 1762339426001

## Action Items
- [ ] Identify what BDK7 refers to (Azure subscription, resource group, or Azure DevOps team)
- [ ] Add Michael Ringholm Sundgaard (mrs@solita.dk) to BDK7 with appropriate permissions
- [ ] Verify access has been granted
- [ ] Notify requestor when complete

## Context
This request originated from a Microsoft Teams message. The user "mrs" (Michael Ringholm Sundgaard) is requesting access to "BDK7", which may require:
- Azure subscription contributor/reader access
- Azure resource group permissions
- Azure DevOps team membership
- GitHub repository/organization access

## Original Teams Message
**Message:** add mrs to BDK7

**Teams Message Metadata:**
- Message ID: 1762339426001
- Sender: Michael Ringholm Sundgaard
- User ID: 81330d43-ae3b-4bb1-b698-4adacf0e5bca
- Tenant ID: 635aa01e-f19d-49ec-8aed-4b2e4312a627 (Solita Denmark)
- Timestamp: 2025-11-05T10:43:46.001Z

## Implementation Scripts

This folder contains Infrastructure as Code (IaC) scripts to implement the access changes:

1. **azure-rbac.sh** - Azure subscription and resource group access
2. **azure-devops.sh** - Azure DevOps team membership
3. **github-access.sh** - GitHub organization and repository access

All scripts use placeholders for sensitive information (tokens, IDs, etc.) that should be provided at execution time.

## Security & Compliance
- All changes follow least privilege principle
- ISO-27001 compliance maintained
- Access granted only as necessary for role requirements
- Audit trail maintained via Teams message and Git history
