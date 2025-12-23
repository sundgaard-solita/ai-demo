# Request: PR Ready Notification

## Summary
Notification from Microsoft Teams indicating that a Pull Request is ready for review in GitHub.

## Message Details

- **Message**: "PR ligger klar i GitHub."
  - **Translation**: "PR is ready in GitHub."
- **Sender**: Michael Ringholm Sundgaard
- **User ID**: 81330d43-ae3b-4bb1-b698-4adacf0e5bca
- **Timestamp**: 2025-11-06T13:09:06.92Z (November 6, 2025 at 13:09:06 UTC)
- **Teams Message ID**: 1762434546920
- **Locale**: en-us
- **Importance**: normal

## Teams Context

- **Team ID**: 45500773-64be-4e45-9aeb-0922cdb2f616
- **Channel ID**: 19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype
- **Message Type**: message
- **Thread Type**: channel

## Links

- **Teams Message**: [View in Teams](https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920)

## Action Items

- [x] Parse and document Teams message
- [ ] Locate the mentioned Pull Request in GitHub
- [ ] Review the Pull Request
- [ ] Provide feedback or approve

## Notes

This notification was sent through Microsoft Teams and automatically converted into a GitHub issue for tracking. The message indicates that someone (Michael Ringholm Sundgaard) has prepared a Pull Request that is now ready for review.

To proceed:
1. Check recent Pull Requests in the repository
2. Look for PRs created or updated around 2025-11-06 13:09 UTC
3. Review the PR content
4. Provide appropriate feedback

## Technical Details

The notification was received via Microsoft Teams Graph API:
- API Endpoint: `https://graph.microsoft.com/v1.0/$metadata#teams('45500773-64be-4e45-9aeb-0922cdb2f616')/channels('19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype')/messages/$entity`
- Status Code: 200
- Request ID: a4f02a39-65ec-4e55-a17f-b2cfd1bde7e1
- Data Center: West Europe
- Tenant ID: 635aa01e-f19d-49ec-8aed-4b2e4312a627

---

## Raw Data

<details>
<summary>Click to expand raw Teams message JSON</summary>

```json
{
  "statusCode": 200,
  "headers": {
    "Transfer-Encoding": "chunked",
    "Vary": "Accept-Encoding",
    "Strict-Transport-Security": "max-age=31536000",
    "request-id": "a4f02a39-65ec-4e55-a17f-b2cfd1bde7e1",
    "client-request-id": "a4f02a39-65ec-4e55-a17f-b2cfd1bde7e1",
    "x-ms-ags-diagnostic": "{\"ServerInfo\":{\"DataCenter\":\"West Europe\",\"Slice\":\"E\",\"Ring\":\"5\",\"ScaleUnit\":\"010\",\"RoleInstance\":\"AM4PEPF00068AC6\"}}",
    "OData-Version": "4.0",
    "x-ms-environment-id": "default-635aa01e-f19d-49ec-8aed-4b2e4312a627",
    "x-ms-tenant-id": "635aa01e-f19d-49ec-8aed-4b2e4312a627",
    "x-ms-dlp-re": "-|-",
    "x-ms-dlp-gu": "-|-",
    "x-ms-dlp-ef": "-|-/-|-|-",
    "x-ms-mip-sl": "-|-|-|-",
    "x-ms-au-creator-id": "81330d43-ae3b-4bb1-b698-4adacf0e5bca",
    "Timing-Allow-Origin": "*",
    "x-ms-apihub-cached-response": "true",
    "x-ms-apihub-obo": "false",
    "Date": "Thu, 06 Nov 2025 13:09:07 GMT",
    "Content-Type": "application/json",
    "Content-Length": "2043"
  },
  "body": {
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#teams('45500773-64be-4e45-9aeb-0922cdb2f616')/channels('19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype')/messages/$entity",
    "id": "1762434546920",
    "replyToId": "1762434546920",
    "etag": "1762434546920",
    "messageType": "message",
    "createdDateTime": "2025-11-06T13:09:06.92Z",
    "lastModifiedDateTime": "2025-11-06T13:09:06.92Z",
    "lastEditedDateTime": null,
    "deletedDateTime": null,
    "subject": null,
    "summary": null,
    "chatId": null,
    "importance": "normal",
    "locale": "en-us",
    "webUrl": "https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920",
    "policyViolation": null,
    "eventDetail": null,
    "from": {
      "application": null,
      "device": null,
      "user": {
        "@odata.type": "#microsoft.graph.teamworkUserIdentity",
        "id": "81330d43-ae3b-4bb1-b698-4adacf0e5bca",
        "displayName": "Michael Ringholm Sundgaard",
        "userIdentityType": "aadUser",
        "tenantId": "635aa01e-f19d-49ec-8aed-4b2e4312a627"
      }
    },
    "body": {
      "contentType": "html",
      "content": "<p>PR ligger klar i GitHub.</p>",
      "plainTextContent": "PR ligger klar i GitHub."
    },
    "channelIdentity": {
      "teamId": "45500773-64be-4e45-9aeb-0922cdb2f616",
      "channelId": "19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"
    },
    "attachments": [],
    "mentions": [],
    "reactions": [],
    "messageLink": "https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762434546920?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762434546920&parentMessageId=1762434546920",
    "threadType": "channel",
    "teamId": "45500773-64be-4e45-9aeb-0922cdb2f616",
    "channelId": "19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"
  }
}
```

</details>
