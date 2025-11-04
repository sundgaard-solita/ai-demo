# Azure AD - Add User to Security Group
# Request ID: 1762261162456
# Description: Add Michael Ringholm Sundgaard (MRS) to RIT5 security group

# Configuration
$userId = "81330d43-ae3b-4bb1-b698-4adacf0e5bca"  # Michael Ringholm Sundgaard
$groupName = "RIT5"
$tenantId = "635aa01e-f19d-49ec-8aed-4b2e4312a627"  # Solita Denmark tenant

# Prerequisites:
# - Azure AD PowerShell module: Install-Module AzureAD
# - Appropriate permissions to manage group membership
# - Authenticated session: Connect-AzureAD -TenantId $tenantId

Write-Host "================================"
Write-Host "Azure AD Group Membership Update"
Write-Host "================================"
Write-Host ""
Write-Host "Request ID: 1762261162456"
Write-Host "User: Michael Ringholm Sundgaard"
Write-Host "User ID: $userId"
Write-Host "Target Group: $groupName"
Write-Host "Tenant: $tenantId"
Write-Host ""

try {
    # Ensure connected to Azure AD
    Write-Host "Connecting to Azure AD..."
    Connect-AzureAD -TenantId $tenantId
    
    # Get the group
    Write-Host "Searching for group: $groupName"
    $group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"
    
    if ($null -eq $group) {
        Write-Error "Group '$groupName' not found in tenant"
        exit 1
    }
    
    Write-Host "Found group: $($group.DisplayName) (ObjectId: $($group.ObjectId))"
    
    # Check if user is already a member
    $existingMember = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object { $_.ObjectId -eq $userId }
    
    if ($existingMember) {
        Write-Warning "User is already a member of group '$groupName'"
        exit 0
    }
    
    # Add user to group
    Write-Host "Adding user to group..."
    Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $userId
    
    # Verify membership
    Write-Host "Verifying membership..."
    Start-Sleep -Seconds 2
    $verifyMember = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object { $_.ObjectId -eq $userId }
    
    if ($verifyMember) {
        Write-Host "SUCCESS: User successfully added to group '$groupName'" -ForegroundColor Green
        Write-Host ""
        Write-Host "Audit Information:"
        Write-Host "- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
        Write-Host "- Request ID: 1762261162456"
        Write-Host "- User: $userId"
        Write-Host "- Group: $($group.ObjectId)"
    } else {
        Write-Error "Failed to verify membership after adding user"
        exit 1
    }
    
} catch {
    Write-Error "Error occurred: $_"
    exit 1
}
