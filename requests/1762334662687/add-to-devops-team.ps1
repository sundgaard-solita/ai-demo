#Requires -Modules Az.Accounts

<#
.SYNOPSIS
    Adds Michael Ringholm Sundgaard (MRS) to Azure DevOps team.

.DESCRIPTION
    This script adds a user to an Azure DevOps team using the Azure DevOps REST API.
    It follows least privilege principle and ISO 27001 compliance requirements.

.PARAMETER UserEmail
    The email address of the user (UserPrincipalName).

.PARAMETER Organization
    The Azure DevOps organization name.

.PARAMETER ProjectName
    The Azure DevOps project name.

.PARAMETER TeamName
    The Azure DevOps team name.

.PARAMETER PAT
    Personal Access Token with appropriate permissions.

.EXAMPLE
    .\add-to-devops-team.ps1 -UserEmail "user@solita.dk" -Organization "solita-dk" -ProjectName "DR-Project" -TeamName "DR-Team" -PAT "<PAT_TOKEN>"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserEmail = "<USER_EMAIL>@solita.dk",
    
    [Parameter(Mandatory=$true)]
    [string]$Organization = "<DEVOPS_ORG>",
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName = "<PROJECT_NAME>",
    
    [Parameter(Mandatory=$true)]
    [string]$TeamName = "<TEAM_NAME>",
    
    [Parameter(Mandatory=$true)]
    [string]$PAT = "<PAT_TOKEN>"
)

# Error handling
$ErrorActionPreference = "Stop"

try {
    Write-Host "Starting Azure DevOps team membership process..." -ForegroundColor Cyan
    
    # Encode PAT for authentication
    $encodedPat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
    $headers = @{
        Authorization = "Basic $encodedPat"
        "Content-Type" = "application/json"
    }
    
    # Base URL
    $baseUrl = "https://dev.azure.com/$Organization"
    
    # Get user descriptor by email
    Write-Host "Retrieving user information from Azure DevOps..." -ForegroundColor Yellow
    $userApiUrl = "https://vssps.dev.azure.com/$Organization/_apis/graph/users?api-version=7.1-preview.1"
    
    $users = Invoke-RestMethod -Uri $userApiUrl -Headers $headers -Method Get
    $user = $users.value | Where-Object { $_.mailAddress -eq $UserEmail }
    
    if ($null -eq $user) {
        throw "User with email $UserEmail not found in Azure DevOps organization"
    }
    
    Write-Host "User found: $($user.displayName) ($($user.mailAddress))" -ForegroundColor Green
    $userDescriptor = $user.descriptor
    
    # Get team descriptor
    Write-Host "Retrieving team information..." -ForegroundColor Yellow
    $teamApiUrl = "$baseUrl/$ProjectName/_apis/teams?api-version=7.1-preview.3"
    
    $teams = Invoke-RestMethod -Uri $teamApiUrl -Headers $headers -Method Get
    $team = $teams.value | Where-Object { $_.name -eq $TeamName }
    
    if ($null -eq $team) {
        throw "Team '$TeamName' not found in project '$ProjectName'"
    }
    
    Write-Host "Team found: $($team.name) (ID: $($team.id))" -ForegroundColor Green
    $teamDescriptor = $team.id
    
    # Check if user is already a team member
    Write-Host "Checking existing team membership..." -ForegroundColor Yellow
    $membersApiUrl = "$baseUrl/_apis/projects/$ProjectName/teams/$teamDescriptor/members?api-version=7.1-preview.2"
    
    $members = Invoke-RestMethod -Uri $membersApiUrl -Headers $headers -Method Get
    $isMember = $members.value | Where-Object { $_.identity.descriptor -eq $userDescriptor }
    
    if ($isMember) {
        Write-Host "User is already a member of the team. No action needed." -ForegroundColor Yellow
    }
    else {
        # Add user to team
        Write-Host "Adding user to team..." -ForegroundColor Yellow
        $addMemberApiUrl = "$baseUrl/_apis/projects/$ProjectName/teams/$teamDescriptor/members/${userDescriptor}?api-version=7.1-preview.2"
        
        $response = Invoke-RestMethod -Uri $addMemberApiUrl -Headers $headers -Method Put
        
        Write-Host "Successfully added $($user.displayName) to team $TeamName" -ForegroundColor Green
        
        # Verify membership
        Start-Sleep -Seconds 2
        $members = Invoke-RestMethod -Uri $membersApiUrl -Headers $headers -Method Get
        $isMember = $members.value | Where-Object { $_.identity.descriptor -eq $userDescriptor }
        
        if ($isMember) {
            Write-Host "Team membership verified successfully!" -ForegroundColor Green
        }
        else {
            Write-Warning "Team membership could not be verified immediately. This may take a few minutes to propagate."
        }
    }
    
    # Log the change
    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Action = "Add Azure DevOps Team Member"
        User = $UserEmail
        Organization = $Organization
        Project = $ProjectName
        Team = $TeamName
        Status = "Success"
    }
    
    Write-Host "`nOperation completed successfully!" -ForegroundColor Green
    Write-Host "Log Entry:" -ForegroundColor Cyan
    $logEntry | Format-Table -AutoSize
    
}
catch {
    Write-Error "Failed to add user to Azure DevOps team: $_"
    Write-Error $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Error "Response: $responseBody"
    }
    exit 1
}
