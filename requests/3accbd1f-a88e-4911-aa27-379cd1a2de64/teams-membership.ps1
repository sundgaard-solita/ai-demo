# Microsoft Teams Membership Assignment
# Request ID: 3accbd1f-a88e-4911-aa27-379cd1a2de64
# Requested by: Michael Ringholm Sundgaard
# Date: 2025-11-04

param(
    [Parameter(Mandatory=$false)]
    [string]$TeamName = "RIT5",
    
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Member", "Owner")]
    [string]$Role = "Member"
)

# Requires Microsoft Teams PowerShell module
if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Write-Host "Installing Microsoft Teams PowerShell module..." -ForegroundColor Yellow
    Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser
}

Import-Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan

try {
    # Connect using managed identity or interactive auth
    Connect-MicrosoftTeams
    
    # Find the team by name
    Write-Host "Looking for team '$TeamName'..." -ForegroundColor Cyan
    $team = Get-Team -DisplayName $TeamName
    
    if (-not $team) {
        Write-Error "Team '$TeamName' not found"
        exit 1
    }
    
    $teamId = $team.GroupId
    Write-Host "Found team: $($team.DisplayName) (ID: $teamId)" -ForegroundColor Green
    
    Write-Host "Adding user $UserPrincipalName to team $TeamName as $Role..." -ForegroundColor Cyan
    
    # Add user to team
    Add-TeamUser -GroupId $teamId -User $UserPrincipalName -Role $Role
    
    Write-Host "✓ Successfully added $UserPrincipalName to $TeamName" -ForegroundColor Green
    
    # Compliance logging
    $auditEntry = @{
        Timestamp = (Get-Date).ToUniversalTime().ToString("o")
        RequestId = "3accbd1f-a88e-4911-aa27-379cd1a2de64"
        Action = "Add Teams Member"
        Team = $TeamName
        TeamId = $teamId
        User = $UserPrincipalName
        Role = $Role
        RequestedBy = "Michael Ringholm Sundgaard"
        TenantId = "635aa01e-f19d-49ec-8aed-4b2e4312a627"
        Status = "Success"
    }
    
    # Log to file for audit trail
    $auditEntry | ConvertTo-Json -Compress | Out-File -Append -FilePath "./audit-log.jsonl"
    
    Write-Host "Audit log updated" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to add user to Teams: $_"
    
    # Log failure for compliance
    $auditEntry = @{
        Timestamp = (Get-Date).ToUniversalTime().ToString("o")
        RequestId = "3accbd1f-a88e-4911-aa27-379cd1a2de64"
        Action = "Add Teams Member"
        Team = $TeamName
        User = $UserPrincipalName
        Role = $Role
        RequestedBy = "Michael Ringholm Sundgaard"
        TenantId = "635aa01e-f19d-49ec-8aed-4b2e4312a627"
        Status = "Failed"
        Error = $_.Exception.Message
    }
    
    $auditEntry | ConvertTo-Json -Compress | Out-File -Append -FilePath "./audit-log.jsonl"
    
    exit 1
} finally {
    Disconnect-MicrosoftTeams
}

Write-Host "Done!" -ForegroundColor Green
