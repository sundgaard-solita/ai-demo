# PowerShell script to add user to Azure DevOps Team
# Add Michael Ringholm Sundgaard (mrs) to DR3 Team in Azure DevOps

# Configuration - Replace these placeholders with actual values
$Organization = "solita"                     # Azure DevOps organization name
$Project = "{PROJECT_NAME}"                  # Azure DevOps project name
$TeamName = "DR3"                            # Team name
$UserEmail = "mrs@solita.dk"                 # User email
$PAT = "{PAT_TOKEN}"                         # Personal Access Token with appropriate permissions

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Add User to Azure DevOps Team" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Organization: $Organization"
Write-Host "  Project: $Project"
Write-Host "  Team: $TeamName"
Write-Host "  User Email: $UserEmail"
Write-Host ""

# Validate PAT token is provided
if ($PAT -eq "{PAT_TOKEN}") {
    Write-Error "Please provide a valid Personal Access Token (PAT)"
    Write-Host "To create a PAT:" -ForegroundColor Yellow
    Write-Host "1. Go to https://dev.azure.com/$Organization/_usersSettings/tokens" -ForegroundColor Yellow
    Write-Host "2. Create a new token with 'Project and Team (read, write, and manage)' scope" -ForegroundColor Yellow
    exit 1
}

# Create authorization header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Azure DevOps REST API base URL
$baseUrl = "https://dev.azure.com/$Organization"

# Get project ID
Write-Host "Getting project information..." -ForegroundColor Yellow
try {
    $projectUrl = "$baseUrl/_apis/projects/$Project?api-version=7.0"
    $projectResponse = Invoke-RestMethod -Uri $projectUrl -Headers $headers -Method Get
    $projectId = $projectResponse.id
    Write-Host "✓ Project found: $($projectResponse.name) (ID: $projectId)" -ForegroundColor Green
} catch {
    Write-Error "Failed to get project: $_"
    exit 1
}

# Get team ID
Write-Host "Getting team information..." -ForegroundColor Yellow
try {
    $teamUrl = "$baseUrl/_apis/projects/$projectId/teams/$TeamName?api-version=7.0"
    $teamResponse = Invoke-RestMethod -Uri $teamUrl -Headers $headers -Method Get
    $teamId = $teamResponse.id
    Write-Host "✓ Team found: $($teamResponse.name) (ID: $teamId)" -ForegroundColor Green
} catch {
    Write-Error "Failed to get team '$TeamName': $_"
    Write-Host "Available teams:" -ForegroundColor Yellow
    try {
        $teamsUrl = "$baseUrl/_apis/projects/$projectId/teams?api-version=7.0"
        $teamsResponse = Invoke-RestMethod -Uri $teamsUrl -Headers $headers -Method Get
        $teamsResponse.value | ForEach-Object { Write-Host "  - $($_.name)" }
    } catch {
        Write-Host "Could not retrieve teams list" -ForegroundColor Red
    }
    exit 1
}

# Get user descriptor
Write-Host "Getting user information..." -ForegroundColor Yellow
try {
    # Search for user by email
    $userSearchUrl = "$baseUrl/_apis/graph/users?api-version=7.0-preview.1"
    $usersResponse = Invoke-RestMethod -Uri $userSearchUrl -Headers $headers -Method Get
    $user = $usersResponse.value | Where-Object { $_.principalName -eq $UserEmail }
    
    if ($null -eq $user) {
        Write-Error "User '$UserEmail' not found in Azure DevOps organization"
        exit 1
    }
    
    $userDescriptor = $user.descriptor
    Write-Host "✓ User found: $($user.displayName) ($UserEmail)" -ForegroundColor Green
} catch {
    Write-Error "Failed to get user: $_"
    exit 1
}

# Check if user is already a team member
Write-Host "Checking team membership..." -ForegroundColor Yellow
try {
    $membersUrl = "$baseUrl/_apis/projects/$projectId/teams/$teamId/members?api-version=7.0"
    $membersResponse = Invoke-RestMethod -Uri $membersUrl -Headers $headers -Method Get
    $existingMember = $membersResponse.value | Where-Object { $_.identity.uniqueName -eq $UserEmail }
    
    if ($existingMember) {
        Write-Host "⚠ User is already a member of team '$TeamName'" -ForegroundColor Yellow
        Write-Host "No action needed." -ForegroundColor Yellow
        exit 0
    }
} catch {
    Write-Warning "Could not check existing membership: $_"
}

# Add user to team
Write-Host "Adding user to team..." -ForegroundColor Yellow
try {
    $addMemberUrl = "$baseUrl/_apis/projects/$projectId/teams/$teamId/members/$userDescriptor`?api-version=7.0"
    $addMemberResponse = Invoke-RestMethod -Uri $addMemberUrl -Headers $headers -Method Put
    
    Write-Host "✓ Successfully added user to team!" -ForegroundColor Green
    Write-Host "  User: $($user.displayName) ($UserEmail)" -ForegroundColor Green
    Write-Host "  Team: $TeamName" -ForegroundColor Green
    Write-Host "  Project: $Project" -ForegroundColor Green
} catch {
    Write-Error "Failed to add user to team: $_"
    exit 1
}

# Display current team members
Write-Host ""
Write-Host "Current team members for '$TeamName':" -ForegroundColor Cyan
try {
    $membersUrl = "$baseUrl/_apis/projects/$projectId/teams/$teamId/members?api-version=7.0"
    $membersResponse = Invoke-RestMethod -Uri $membersUrl -Headers $headers -Method Get
    $membersResponse.value | ForEach-Object {
        Write-Host "  - $($_.identity.displayName) ($($_.identity.uniqueName))"
    }
} catch {
    Write-Warning "Could not retrieve team members list"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Operation completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
