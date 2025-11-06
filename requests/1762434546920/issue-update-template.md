# Issue Update Template

## Suggested Issue Title
```
Teams Notification: PR Ready for Review - Michael Ringholm Sundgaard
```

## Suggested Issue Body
```markdown
## Summary
Notification from Microsoft Teams: A Pull Request is ready for review in GitHub.

## Message
**"PR ligger klar i GitHub."**  
_Translation: "PR is ready in GitHub."_

## Details
- **From**: Michael Ringholm Sundgaard
- **Sent**: November 6, 2025 at 13:09:06 UTC
- **Teams Message ID**: 1762434546920

## Action Required
1. Locate the Pull Request mentioned in this notification
2. Review the PR content
3. Provide feedback or approval

## Links
- [View original message in Teams](https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920)

---

_This issue was automatically processed from a Microsoft Teams message._
```

## Script to Update Issue (requires gh CLI with appropriate permissions)

```bash
#!/bin/bash

# Issue number - replace with actual issue number
ISSUE_NUMBER="<ISSUE_NUMBER>"
REPO="sundgaard-solita/ai-demo"

# New title
TITLE="Teams Notification: PR Ready for Review - Michael Ringholm Sundgaard"

# New body
BODY='## Summary
Notification from Microsoft Teams: A Pull Request is ready for review in GitHub.

## Message
**"PR ligger klar i GitHub."**  
_Translation: "PR is ready in GitHub."_

## Details
- **From**: Michael Ringholm Sundgaard
- **Sent**: November 6, 2025 at 13:09:06 UTC
- **Teams Message ID**: 1762434546920

## Action Required
1. Locate the Pull Request mentioned in this notification
2. Review the PR content
3. Provide feedback or approval

## Links
- [View original message in Teams](https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920)

---

_This issue was automatically processed from a Microsoft Teams message._'

# Update the issue
gh issue edit "$ISSUE_NUMBER" \
  --repo "$REPO" \
  --title "$TITLE" \
  --body "$BODY"

echo "Issue #$ISSUE_NUMBER updated successfully!"
```

## PowerShell Script Alternative

```powershell
# Issue number - replace with actual issue number
$IssueNumber = "<ISSUE_NUMBER>"
$Repo = "sundgaard-solita/ai-demo"

# New title
$Title = "Teams Notification: PR Ready for Review - Michael Ringholm Sundgaard"

# New body
$Body = @"
## Summary
Notification from Microsoft Teams: A Pull Request is ready for review in GitHub.

## Message
**"PR ligger klar i GitHub."**  
_Translation: "PR is ready in GitHub."_

## Details
- **From**: Michael Ringholm Sundgaard
- **Sent**: November 6, 2025 at 13:09:06 UTC
- **Teams Message ID**: 1762434546920

## Action Required
1. Locate the Pull Request mentioned in this notification
2. Review the PR content
3. Provide feedback or approval

## Links
- [View original message in Teams](https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920)

---

_This issue was automatically processed from a Microsoft Teams message._
"@

# Update the issue
gh issue edit $IssueNumber `
  --repo $Repo `
  --title $Title `
  --body $Body

Write-Host "Issue #$IssueNumber updated successfully!"
```

## Manual Update Instructions

If you need to update the issue manually:

1. Navigate to the issue on GitHub
2. Click "Edit" on the issue title
3. Replace the title with: `Teams Notification: PR Ready for Review - Michael Ringholm Sundgaard`
4. Click "Edit" on the issue body
5. Replace the body with the markdown content shown above
6. Save the changes
