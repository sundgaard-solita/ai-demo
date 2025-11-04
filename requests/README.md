# Requests Directory

This directory contains processed requests from Microsoft Teams messages and other sources. Each request is organized in its own subdirectory with complete documentation and automation scripts.

## Structure

```
requests/
├── README.md (this file)
└── {request-id}/
    ├── README.md           # Detailed request information
    ├── QUICKSTART.md       # Quick start guide
    ├── config.env          # Configuration file
    ├── run.sh              # Interactive master script
    ├── audit-log.txt       # Operation audit log (generated)
    └── *.sh                # Individual automation scripts
```

## Request Tracking

Each request is identified by its unique ID (typically from the Teams message ID) and contains:

1. **Request Information**: Original message, requester, timestamp
2. **Task Description**: Detailed breakdown of the request
3. **Action Items**: Checklist of tasks to complete
4. **Automation Scripts**: Infrastructure as Code (IaC) for various platforms
5. **Audit Trail**: Logs of all operations performed

## Available Requests

### [1762259868977](./1762259868977/) - Add MRS to RIT2
- **Status**: Pending
- **Date**: 2025-11-04
- **Task**: Add Michael Ringholm Sundgaard to RIT2
- **Platforms**: Azure AD, Azure RBAC, Azure DevOps, GitHub, Microsoft Teams

## How to Process a Request

1. **Navigate to request directory**:
   ```bash
   cd requests/{request-id}
   ```

2. **Read the request details**:
   ```bash
   cat README.md
   # or
   cat QUICKSTART.md
   ```

3. **Run the interactive script**:
   ```bash
   ./run.sh
   ```

4. **Or run individual scripts**:
   ```bash
   source config.env
   ./azure-ad-group.sh
   ./azure-rbac.sh
   # etc.
   ```

5. **Verify and document**:
   - Check audit log
   - Update issue status
   - Notify requester

## Platform Support

Our automation scripts support:

- **Azure AD**: User and group management
- **Azure RBAC**: Resource group permissions
- **Azure DevOps**: Project and team management
- **GitHub**: Organization and team management
- **Microsoft Teams**: Team membership management

## Security & Compliance

All scripts follow:

- ✅ ISO-27001 compliance requirements
- ✅ Least privilege principle
- ✅ Proper audit logging
- ✅ Secure token management
- ✅ Access control validation

## Best Practices

1. **Always review** the request details before executing scripts
2. **Test in non-production** environments first
3. **Verify authorization** before granting access
4. **Document operations** in the audit log
5. **Follow up** with the requester after completion
6. **Keep tokens secure** - use environment variables, never commit

## Adding New Requests

When a new request comes in (e.g., from Teams):

1. Create a new subdirectory with the request ID
2. Copy the template structure from an existing request
3. Update configuration and scripts as needed
4. Document the request in README.md
5. Update this directory listing

## Template Structure

Use this as a template for new requests:

```bash
mkdir -p requests/{new-request-id}
cd requests/{new-request-id}

# Create basic files
touch README.md QUICKSTART.md config.env run.sh

# Create platform-specific scripts as needed
touch azure-ad-group.sh azure-rbac.sh azure-devops.sh
touch github-team.sh teams-member.sh

# Make scripts executable
chmod +x *.sh
```

## Maintenance

- Archive completed requests after 90 days
- Keep audit logs for compliance (as per retention policy)
- Review and update scripts as platforms evolve
- Update documentation with lessons learned

## Support

For questions or issues:
- Check individual request documentation
- Review script error messages
- Contact IT support or security team
- Consult the main repository README.md

## Related Documentation

- [Main Repository README](../README.md)
- [Instructions for AI Agent](../instructions.md)
- [GitHub Workflows](../.github/workflows/)
