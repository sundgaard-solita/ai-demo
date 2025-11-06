#Requires -Modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Adds Michael Ringholm Sundgaard (MRS) to Azure AD security group for DR team.

.DESCRIPTION
    This script adds a user to an Azure AD security group to grant access to DR team resources.
    It follows least privilege principle and ISO 27001 compliance requirements.

.PARAMETER UserObjectId
    The Azure AD object ID of the user to add.

.PARAMETER GroupName
    The name of the Azure AD group to add the user to.

.PARAMETER TenantId
    The Azure tenant ID.

.EXAMPLE
    .\add-to-azure-ad-group.ps1 -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" -GroupName "DR-Team-Members" -TenantId "<TENANT_ID>"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserObjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$GroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$TenantId
)

# Error handling
$ErrorActionPreference = "Stop"

try {
    Write-Host "Starting Azure AD group membership process..." -ForegroundColor Cyan
    
    # Connect to Azure
    Write-Host "Connecting to Azure AD tenant: $TenantId" -ForegroundColor Yellow
    Connect-AzAccount -Tenant $TenantId
    
    # Get the user details
    Write-Host "Retrieving user information..." -ForegroundColor Yellow
    $user = Get-AzADUser -ObjectId $UserObjectId
    
    if ($null -eq $user) {
        throw "User with ObjectId $UserObjectId not found"
    }
    
    Write-Host "User found: $($user.DisplayName) ($($user.UserPrincipalName))" -ForegroundColor Green
    
    # Get the group
    Write-Host "Retrieving Azure AD group: $GroupName" -ForegroundColor Yellow
    $group = Get-AzADGroup -DisplayName $GroupName
    
    if ($null -eq $group) {
        throw "Azure AD group '$GroupName' not found"
    }
    
    Write-Host "Group found: $($group.DisplayName) (ID: $($group.Id))" -ForegroundColor Green
    
    # Check if user is already a member
    Write-Host "Checking existing group membership..." -ForegroundColor Yellow
    $members = Get-AzADGroupMember -GroupObjectId $group.Id
    $isMember = $members | Where-Object { $_.Id -eq $UserObjectId }
    
    if ($isMember) {
        Write-Host "User is already a member of the group. No action needed." -ForegroundColor Yellow
    }
    else {
        # Add user to group
        Write-Host "Adding user to group..." -ForegroundColor Yellow
        Add-AzADGroupMember -TargetGroupObjectId $group.Id -MemberObjectId $UserObjectId
        
        Write-Host "Successfully added $($user.DisplayName) to $GroupName" -ForegroundColor Green
        
        # Verify membership
        Start-Sleep -Seconds 2
        $members = Get-AzADGroupMember -GroupObjectId $group.Id
        $isMember = $members | Where-Object { $_.Id -eq $UserObjectId }
        
        if ($isMember) {
            Write-Host "Membership verified successfully!" -ForegroundColor Green
        }
        else {
            Write-Warning "Membership could not be verified immediately. This may take a few minutes to propagate."
        }
    }
    
    # Log the change
    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Action = "Add Azure AD Group Member"
        User = $user.UserPrincipalName
        Group = $GroupName
        Status = "Success"
    }
    
    Write-Host "`nOperation completed successfully!" -ForegroundColor Green
    Write-Host "Log Entry:" -ForegroundColor Cyan
    $logEntry | Format-Table -AutoSize
    
}
catch {
    Write-Error "Failed to add user to Azure AD group: $_"
    exit 1
}
