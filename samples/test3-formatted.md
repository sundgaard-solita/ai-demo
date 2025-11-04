# Formatted Output for Issue "Test3"

This document shows the formatted output for the raw Teams message data from issue "Test3".

## Formatted Issue Title
```
Add user 'mrs' to BDK
```

## Formatted Issue Description

```markdown
## Summary
Request to add user 'mrs' to BDK system/team.

## Request Details
- **Requested by:** Michael Ringholm Sundgaard
- **Date:** November 3, 2025 at 09:23 UTC
- **Source:** Microsoft Teams
- **Message ID:** 1762161794215

## Action Items
- [ ] Add user 'mrs' to BDK system/team
- [ ] Verify user permissions and access levels
- [ ] Confirm completion with requester

## Original Message
> add user mrs to bdk

## Technical Details
- **Requester User ID:** 81330d43-ae3b-4bb1-b698-4adacf0e5bca
- **Tenant ID:** 635aa01e-f19d-49ec-8aed-4b2e4312a627
- **Teams Message Link:** [View in Teams](https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762161794215?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&createdTime=1762161794215&parentMessageId=1762161794215)

---
*This issue was automatically created from a Microsoft Teams message on 2025-11-03.*
```

## Original Raw Data

The original raw Teams message JSON from issue "Test3" was:
```json
[{"statusCode":200,"headers":{"Transfer-Encoding":"chunked","Vary":"Accept-Encoding","Strict-Transport-Security":"max-age=31536000","request-id":"848bd3fa-fcfb-4995-b5c2-eadc0f2d4d3b","client-request-id":"848bd3fa-fcfb-4995-b5c2-eadc0f2d4d3b","x-ms-ags-diagnostic":"{"ServerInfo":{"DataCenter":"West Europe","Slice":"E","Ring":"5","ScaleUnit":"008","RoleInstance":"AM2PEPF00044C0F"}}","OData-Version":"4.0","x-ms-environment-id":"default-635aa01e-f19d-49ec-8aed-4b2e4312a627","x-ms-tenant-id":"635aa01e-f19d-49ec-8aed-4b2e4312a627","x-ms-dlp-re":"-|-","x-ms-dlp-gu":"-|-","x-ms-dlp-ef":"-|-/-|-|-","x-ms-mip-sl":"-|-|-|-","x-ms-au-creator-id":"81330d43-ae3b-4bb1-b698-4adacf0e5bca","Timing-Allow-Origin":"*","x-ms-apihub-cached-response":"false","x-ms-apihub-obo":"false","Date":"Mon, 03 Nov 2025 09:23:14 GMT","Content-Type":"application/json","Content-Length":"2035"},"body":{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#teams('45500773-64be-4e45-9aeb-0922cdb2f616')/channels('19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype')/messages/$entity","id":"1762161794215","replyToId":"1762161794215","etag":"1762161794215","messageType":"message","createdDateTime":"2025-11-03T09:23:14.215Z","lastModifiedDateTime":"2025-11-03T09:23:14.215Z","lastEditedDateTime":null,"deletedDateTime":null,"subject":null,"summary":null,"chatId":null,"importance":"normal","locale":"en-us","webUrl":"https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762161794215?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&amp;tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&amp;createdTime=1762161794215&amp;parentMessageId=1762161794215","policyViolation":null,"eventDetail":null,"from":{"application":null,"device":null,"user":{"@odata.type":"#microsoft.graph.teamworkUserIdentity","id":"81330d43-ae3b-4bb1-b698-4adacf0e5bca","displayName":"Michael Ringholm Sundgaard","userIdentityType":"aadUser","tenantId":"635aa01e-f19d-49ec-8aed-4b2e4312a627"}},"body":{"contentType":"html","content":"<p>add user mrs to bdk</p>","plainTextContent":"add user mrs to bdk"},"channelIdentity":{"teamId":"45500773-64be-4e45-9aeb-0922cdb2f616","channelId":"19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"},"attachments":[],"mentions":[],"reactions":[],"messageLink":"https://teams.microsoft.com/l/message/19%3A3a3f2ddfdac14235bd81c8d7cc642cd2%40thread.skype/1762161794215?groupId=45500773-64be-4e45-9aeb-0922cdb2f616&amp;tenantId=635aa01e-f19d-49ec-8aed-4b2e4312a627&amp;createdTime=1762161794215&amp;parentMessageId=1762161794215","threadType":"channel","teamId":"45500773-64be-4e45-9aeb-0922cdb2f616","channelId":"19:3a3f2ddfdac14235bd81c8d7cc642cd2@thread.skype"}}]
```

## Processing Summary

The custom agent successfully:
1. ✅ Extracted the human message: "add user mrs to bdk"
2. ✅ Identified sender: Michael Ringholm Sundgaard
3. ✅ Captured timestamp: November 3, 2025, 09:23 UTC
4. ✅ Created clear title: "Add user 'mrs' to BDK"
5. ✅ Formatted description with proper markdown structure
6. ✅ Included relevant context (requester, date, source)
7. ✅ Listed action items in a checkbox format
8. ✅ Preserved technical details for traceability
9. ✅ Added direct link back to the Teams message
