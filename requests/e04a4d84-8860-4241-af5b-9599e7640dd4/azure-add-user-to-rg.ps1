# PowerShell script to add user to Azure Resource Group
# Add Michael Ringholm Sundgaard (mrs) to DR3 Resource Group

# Configuration - Replace these placeholders with actual values
$TenantId = "{TENANT_ID}"                    # e.g., "635aa01e-f19d-49ec-8aed-4b2e4312a627"
$SubscriptionId = "{SUBSCRIPTION_ID}"        # Azure Subscription ID
$ResourceGroupName = "DR3"                   # Resource Group name
$UserEmail = "mrs@solita.dk"                 # User email
$RoleName = "Contributor"                    # RBAC role: Reader, Contributor, Owner, etc.

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Add User to Azure Resource Group" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Tenant ID: $TenantId"
Write-Host "  Subscription ID: $SubscriptionId"
Write-Host "  Resource Group: $ResourceGroupName"
Write-Host "  User Email: $UserEmail"
Write-Host "  Role: $RoleName"
Write-Host ""

# Check if Azure PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Write-Host "Azure PowerShell module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

# Import Azure module
Import-Module Az.Accounts
Import-Module Az.Resources

# Connect to Azure
Write-Host "Connecting to Azure..." -ForegroundColor Yellow
try {
    Connect-AzAccount -TenantId $TenantId
    Write-Host "Successfully connected to Azure" -ForegroundColor Green
} catch {
    Write-Error "Failed to connect to Azure: $_"
    exit 1
}

# Set subscription context
Write-Host "Setting subscription context..." -ForegroundColor Yellow
try {
    Set-AzContext -SubscriptionId $SubscriptionId
    Write-Host "Successfully set subscription context" -ForegroundColor Green
} catch {
    Write-Error "Failed to set subscription: $_"
    exit 1
}

# Verify resource group exists
Write-Host "Verifying resource group exists..." -ForegroundColor Yellow
try {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
    Write-Host "Resource group found: $($rg.ResourceGroupName)" -ForegroundColor Green
} catch {
    Write-Error "Resource group '$ResourceGroupName' not found: $_"
    exit 1
}

# Get user object ID
Write-Host "Getting user object ID..." -ForegroundColor Yellow
try {
    $user = Get-AzADUser -UserPrincipalName $UserEmail
    if ($null -eq $user) {
        Write-Error "User '$UserEmail' not found in Azure AD"
        exit 1
    }
    Write-Host "User found: $($user.DisplayName) (ID: $($user.Id))" -ForegroundColor Green
} catch {
    Write-Error "Failed to get user: $_"
    exit 1
}

# Check if user already has the role assignment
Write-Host "Checking existing role assignments..." -ForegroundColor Yellow
$existingAssignment = Get-AzRoleAssignment -ObjectId $user.Id -ResourceGroupName $ResourceGroupName -RoleDefinitionName $RoleName -ErrorAction SilentlyContinue

if ($existingAssignment) {
    Write-Host "User already has '$RoleName' role on resource group '$ResourceGroupName'" -ForegroundColor Yellow
    Write-Host "No action needed." -ForegroundColor Yellow
} else {
    # Assign role to user
    Write-Host "Assigning '$RoleName' role to user on resource group..." -ForegroundColor Yellow
    try {
        $assignment = New-AzRoleAssignment `
            -ObjectId $user.Id `
            -ResourceGroupName $ResourceGroupName `
            -RoleDefinitionName $RoleName
        
        Write-Host "Successfully assigned role!" -ForegroundColor Green
        Write-Host "  User: $($user.DisplayName) ($UserEmail)" -ForegroundColor Green
        Write-Host "  Role: $RoleName" -ForegroundColor Green
        Write-Host "  Scope: Resource Group '$ResourceGroupName'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to assign role: $_"
        exit 1
    }
}

# Display current role assignments for the resource group
Write-Host ""
Write-Host "Current role assignments for resource group '$ResourceGroupName':" -ForegroundColor Cyan
Get-AzRoleAssignment -ResourceGroupName $ResourceGroupName | 
    Format-Table DisplayName, RoleDefinitionName, ObjectType -AutoSize

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Operation completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
