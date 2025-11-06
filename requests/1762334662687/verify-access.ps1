#Requires -Modules Az.Accounts, Az.Resources

<#
.SYNOPSIS
    Verifies that Michael Ringholm Sundgaard (MRS) has been granted access to all DR resources.

.DESCRIPTION
    This script verifies that the user has been successfully added to:
    - Azure AD groups
    - Azure Resource Groups (RBAC)
    - Azure DevOps teams

.PARAMETER UserObjectId
    The Azure AD object ID of the user.

.PARAMETER UserEmail
    The email address of the user.

.PARAMETER TenantId
    The Azure tenant ID.

.PARAMETER SubscriptionId
    The Azure subscription ID.

.PARAMETER ResourceGroupName
    The name of the Azure Resource Group.

.PARAMETER ADGroupName
    The name of the Azure AD group.

.PARAMETER DevOpsOrg
    The Azure DevOps organization name.

.PARAMETER ProjectName
    The Azure DevOps project name.

.PARAMETER TeamName
    The Azure DevOps team name.

.PARAMETER PAT
    Personal Access Token for Azure DevOps.

.EXAMPLE
    .\verify-access.ps1 -UserObjectId "81330d43-ae3b-4bb1-b698-4adacf0e5bca" -UserEmail "user@solita.dk" -TenantId "<TENANT_ID>" -SubscriptionId "<SUBSCRIPTION_ID>" -ResourceGroupName "DR-Resources" -ADGroupName "DR-Team-Members" -DevOpsOrg "solita-dk" -ProjectName "DR-Project" -TeamName "DR-Team" -PAT "<PAT_TOKEN>"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserObjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$UserEmail,
    
    [Parameter(Mandatory=$true)]
    [string]$TenantId,
    
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ADGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$DevOpsOrg,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$TeamName,
    
    [Parameter(Mandatory=$true)]
    [string]$PAT
)

# Error handling
$ErrorActionPreference = "Stop"

$verificationResults = @()

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Access Verification Report" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Connect to Azure
    Write-Host "Connecting to Azure..." -ForegroundColor Yellow
    $connection = Connect-AzAccount -Tenant $TenantId
    
    if ($null -eq $connection) {
        throw "Failed to connect to Azure. Please check your credentials and tenant ID."
    }
    
    $context = Set-AzContext -SubscriptionId $SubscriptionId
    
    if ($null -eq $context) {
        throw "Failed to set Azure context. Please check your subscription ID."
    }
    
    Write-Host "Successfully connected to Azure tenant: $TenantId" -ForegroundColor Green
    
    # Get user info
    $user = Get-AzADUser -ObjectId $UserObjectId
    Write-Host "Verifying access for: $($user.DisplayName) ($($user.UserPrincipalName))" -ForegroundColor Green
    Write-Host ""
    
    # 1. Verify Azure AD Group Membership
    Write-Host "1. Checking Azure AD Group Membership..." -ForegroundColor Yellow
    try {
        $group = Get-AzADGroup -DisplayName $ADGroupName
        $members = Get-AzADGroupMember -GroupObjectId $group.Id
        $isMember = $members | Where-Object { $_.Id -eq $UserObjectId }
        
        if ($isMember) {
            Write-Host "   ✓ User IS a member of Azure AD group '$ADGroupName'" -ForegroundColor Green
            $verificationResults += [PSCustomObject]@{
                Check = "Azure AD Group"
                Resource = $ADGroupName
                Status = "✓ Pass"
            }
        }
        else {
            Write-Host "   ✗ User IS NOT a member of Azure AD group '$ADGroupName'" -ForegroundColor Red
            $verificationResults += [PSCustomObject]@{
                Check = "Azure AD Group"
                Resource = $ADGroupName
                Status = "✗ Fail"
            }
        }
    }
    catch {
        Write-Host "   ⚠ Error checking Azure AD group: $_" -ForegroundColor Red
        $verificationResults += [PSCustomObject]@{
            Check = "Azure AD Group"
            Resource = $ADGroupName
            Status = "⚠ Error"
        }
    }
    Write-Host ""
    
    # 2. Verify Azure Resource Group RBAC
    Write-Host "2. Checking Azure Resource Group RBAC..." -ForegroundColor Yellow
    try {
        $roleAssignments = Get-AzRoleAssignment -ObjectId $UserObjectId -ResourceGroupName $ResourceGroupName
        
        if ($roleAssignments.Count -gt 0) {
            Write-Host "   ✓ User HAS role assignments on Resource Group '$ResourceGroupName'" -ForegroundColor Green
            foreach ($assignment in $roleAssignments) {
                Write-Host "      - Role: $($assignment.RoleDefinitionName)" -ForegroundColor Cyan
                $verificationResults += [PSCustomObject]@{
                    Check = "Azure RBAC"
                    Resource = "$ResourceGroupName ($($assignment.RoleDefinitionName))"
                    Status = "✓ Pass"
                }
            }
        }
        else {
            Write-Host "   ✗ User DOES NOT have any role assignments on Resource Group '$ResourceGroupName'" -ForegroundColor Red
            $verificationResults += [PSCustomObject]@{
                Check = "Azure RBAC"
                Resource = $ResourceGroupName
                Status = "✗ Fail"
            }
        }
    }
    catch {
        Write-Host "   ⚠ Error checking Resource Group RBAC: $_" -ForegroundColor Red
        $verificationResults += [PSCustomObject]@{
            Check = "Azure RBAC"
            Resource = $ResourceGroupName
            Status = "⚠ Error"
        }
    }
    Write-Host ""
    
    # 3. Verify Azure DevOps Team Membership
    Write-Host "3. Checking Azure DevOps Team Membership..." -ForegroundColor Yellow
    try {
        $encodedPat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
        $headers = @{
            Authorization = "Basic $encodedPat"
            "Content-Type" = "application/json"
        }
        
        $baseUrl = "https://dev.azure.com/$DevOpsOrg"
        
        # Get team
        $teamApiUrl = "$baseUrl/$ProjectName/_apis/teams?api-version=7.1-preview.3"
        $teams = Invoke-RestMethod -Uri $teamApiUrl -Headers $headers -Method Get
        $team = $teams.value | Where-Object { $_.name -eq $TeamName }
        
        if ($team) {
            $membersApiUrl = "$baseUrl/_apis/projects/$ProjectName/teams/$($team.id)/members?api-version=7.1-preview.2"
            $members = Invoke-RestMethod -Uri $membersApiUrl -Headers $headers -Method Get
            $isMember = $members.value | Where-Object { $_.identity.mailAddress -eq $UserEmail }
            
            if ($isMember) {
                Write-Host "   ✓ User IS a member of Azure DevOps team '$TeamName'" -ForegroundColor Green
                $verificationResults += [PSCustomObject]@{
                    Check = "Azure DevOps Team"
                    Resource = "$ProjectName/$TeamName"
                    Status = "✓ Pass"
                }
            }
            else {
                Write-Host "   ✗ User IS NOT a member of Azure DevOps team '$TeamName'" -ForegroundColor Red
                $verificationResults += [PSCustomObject]@{
                    Check = "Azure DevOps Team"
                    Resource = "$ProjectName/$TeamName"
                    Status = "✗ Fail"
                }
            }
        }
        else {
            Write-Host "   ⚠ Team '$TeamName' not found" -ForegroundColor Red
            $verificationResults += [PSCustomObject]@{
                Check = "Azure DevOps Team"
                Resource = "$ProjectName/$TeamName"
                Status = "⚠ Not Found"
            }
        }
    }
    catch {
        Write-Host "   ⚠ Error checking Azure DevOps team: $_" -ForegroundColor Red
        $verificationResults += [PSCustomObject]@{
            Check = "Azure DevOps Team"
            Resource = "$ProjectName/$TeamName"
            Status = "⚠ Error"
        }
    }
    Write-Host ""
    
    # Summary
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "Verification Summary" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    $verificationResults | Format-Table -AutoSize
    
    $passCount = ($verificationResults | Where-Object { $_.Status -like "*Pass*" }).Count
    $failCount = ($verificationResults | Where-Object { $_.Status -like "*Fail*" }).Count
    $errorCount = ($verificationResults | Where-Object { $_.Status -like "*Error*" -or $_.Status -like "*Not Found*" }).Count
    
    Write-Host "Passed: $passCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
    Write-Host "Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Yellow" } else { "Gray" })
    Write-Host ""
    
    if ($failCount -eq 0 -and $errorCount -eq 0) {
        Write-Host "✓ All access verifications passed!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "⚠ Some access verifications did not pass. Please review the results above." -ForegroundColor Yellow
        exit 1
    }
    
}
catch {
    Write-Error "Verification failed: $_"
    exit 1
}
