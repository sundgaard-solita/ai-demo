#Requires -Modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Grants Michael Ringholm Sundgaard (MRS) RBAC permissions on DR Azure Resource Group.

.DESCRIPTION
    This script assigns role-based access control (RBAC) permissions to a user on an Azure Resource Group.
    It follows least privilege principle and ISO 27001 compliance requirements.

.PARAMETER UserObjectId
    The Azure AD object ID of the user.

.PARAMETER ResourceGroupName
    The name of the Azure Resource Group.

.PARAMETER RoleName
    The RBAC role to assign (e.g., "Contributor", "Reader", "Owner").

.PARAMETER SubscriptionId
    The Azure subscription ID.

.EXAMPLE
    .\add-to-resource-group.ps1 -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" -ResourceGroupName "DR-Resources" -RoleName "Contributor" -SubscriptionId "<SUBSCRIPTION_ID>" -TenantId "<TENANT_ID>"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserObjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Reader", "Contributor", "Owner")]
    [string]$RoleName = "Contributor",
    
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$TenantId
)

# Error handling
$ErrorActionPreference = "Stop"

try {
    Write-Host "Starting Azure Resource Group RBAC assignment process..." -ForegroundColor Cyan
    
    # Connect to Azure
    Write-Host "Connecting to Azure subscription: $SubscriptionId" -ForegroundColor Yellow
    Connect-AzAccount -Tenant $TenantId
    Set-AzContext -SubscriptionId $SubscriptionId
    
    # Get the user details
    Write-Host "Retrieving user information..." -ForegroundColor Yellow
    $user = Get-AzADUser -ObjectId $UserObjectId
    
    if ($null -eq $user) {
        throw "User with ObjectId $UserObjectId not found"
    }
    
    Write-Host "User found: $($user.DisplayName) ($($user.UserPrincipalName))" -ForegroundColor Green
    
    # Get the resource group
    Write-Host "Retrieving Resource Group: $ResourceGroupName" -ForegroundColor Yellow
    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
    
    if ($null -eq $resourceGroup) {
        throw "Resource Group '$ResourceGroupName' not found"
    }
    
    Write-Host "Resource Group found: $($resourceGroup.ResourceGroupName) (Location: $($resourceGroup.Location))" -ForegroundColor Green
    
    # Check if user already has this role assignment
    Write-Host "Checking existing role assignments..." -ForegroundColor Yellow
    $existingAssignment = Get-AzRoleAssignment -ObjectId $UserObjectId `
                                              -ResourceGroupName $ResourceGroupName `
                                              -RoleDefinitionName $RoleName `
                                              -ErrorAction SilentlyContinue
    
    if ($existingAssignment) {
        Write-Host "User already has '$RoleName' role on this Resource Group. No action needed." -ForegroundColor Yellow
    }
    else {
        # Assign role
        Write-Host "Assigning '$RoleName' role to user on Resource Group..." -ForegroundColor Yellow
        $assignment = New-AzRoleAssignment -ObjectId $UserObjectId `
                                          -ResourceGroupName $ResourceGroupName `
                                          -RoleDefinitionName $RoleName
        
        Write-Host "Successfully assigned '$RoleName' role to $($user.DisplayName) on $ResourceGroupName" -ForegroundColor Green
        
        # Verify assignment
        Start-Sleep -Seconds 2
        $verifyAssignment = Get-AzRoleAssignment -ObjectId $UserObjectId `
                                                -ResourceGroupName $ResourceGroupName `
                                                -RoleDefinitionName $RoleName
        
        if ($verifyAssignment) {
            Write-Host "Role assignment verified successfully!" -ForegroundColor Green
        }
        else {
            Write-Warning "Role assignment could not be verified immediately. This may take a few minutes to propagate."
        }
    }
    
    # Display all role assignments for this user on this resource group
    Write-Host "`nAll role assignments for $($user.DisplayName) on ${ResourceGroupName}:" -ForegroundColor Cyan
    $allAssignments = Get-AzRoleAssignment -ObjectId $UserObjectId -ResourceGroupName $ResourceGroupName
    $allAssignments | Select-Object DisplayName, RoleDefinitionName, Scope | Format-Table -AutoSize
    
    # Log the change
    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Action = "Assign RBAC Role"
        User = $user.UserPrincipalName
        ResourceGroup = $ResourceGroupName
        Role = $RoleName
        Status = "Success"
    }
    
    Write-Host "`nOperation completed successfully!" -ForegroundColor Green
    Write-Host "Log Entry:" -ForegroundColor Cyan
    $logEntry | Format-Table -AutoSize
    
}
catch {
    Write-Error "Failed to assign role to user on Resource Group: $_"
    exit 1
}
