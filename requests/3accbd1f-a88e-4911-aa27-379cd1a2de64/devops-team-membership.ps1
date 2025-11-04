# Azure DevOps Team Membership Assignment
# Request ID: 3accbd1f-a88e-4911-aa27-379cd1a2de64
# Requested by: Michael Ringholm Sundgaard
# Date: 2025-11-04

param(
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "RIT5",
    
    [Parameter(Mandatory=$true)]
    [string]$UserEmail,
    
    [Parameter(Mandatory=$false)]
    [string]$TeamName = "RIT5",
    
    [Parameter(Mandatory=$false)]
    [string]$PAT  # Personal Access Token
)

# Security: Use environment variable or Azure Key Vault for PAT
if (-not $PAT) {
    $PAT = $env:AZURE_DEVOPS_PAT
}

if (-not $PAT) {
    Write-Error "Personal Access Token required. Set AZURE_DEVOPS_PAT environment variable or pass -PAT parameter"
    exit 1
}

# Install Azure DevOps CLI extension if not present
Write-Host "Checking Azure DevOps CLI extension..." -ForegroundColor Cyan
az extension add --name azure-devops 2>$null

# Configure Azure DevOps defaults
$env:AZURE_DEVOPS_EXT_PAT = $PAT
az devops configure --defaults organization="https://dev.azure.com/$Organization" project="$ProjectName"

Write-Host "Adding user $UserEmail to team $TeamName in project $ProjectName..." -ForegroundColor Cyan

try {
    # Add user to team
    az devops team add-member `
        --team $TeamName `
        --user $UserEmail `
        --org "https://dev.azure.com/$Organization" `
        --project $ProjectName
    
    Write-Host "✓ Successfully added $UserEmail to $TeamName" -ForegroundColor Green
    
    # Log for compliance
    $logEntry = @{
        Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
        RequestId = "3accbd1f-a88e-4911-aa27-379cd1a2de64"
        Action = "Add Team Member"
        User = $UserEmail
        Team = $TeamName
        Project = $ProjectName
        Organization = $Organization
        RequestedBy = "Michael Ringholm Sundgaard"
        Status = "Success"
    }
    
    $logEntry | ConvertTo-Json -Compress | Out-File -Append -FilePath "./audit-log.jsonl"
    Write-Host "Audit log updated" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to add user to team: $_"
    
    # Log failure for compliance
    $logEntry = @{
        Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
        RequestId = "3accbd1f-a88e-4911-aa27-379cd1a2de64"
        Action = "Add Team Member"
        User = $UserEmail
        Team = $TeamName
        Project = $ProjectName
        Organization = $Organization
        RequestedBy = "Michael Ringholm Sundgaard"
        Status = "Failed"
        Error = $_.Exception.Message
    }
    
    $logEntry | ConvertTo-Json -Compress | Out-File -Append -FilePath "./audit-log.jsonl"
    exit 1
}

Write-Host "Done!" -ForegroundColor Green
