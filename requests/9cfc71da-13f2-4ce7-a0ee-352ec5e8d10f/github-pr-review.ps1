# GitHub PR Review Script (PowerShell)
# This script can be used to interact with GitHub PRs when a notification is received from Teams
#
# Prerequisites:
# - GitHub CLI (gh) installed
# - Authenticated with GitHub (gh auth login)
# - Appropriate permissions to access the repository
#
# Usage:
#   .\github-pr-review.ps1 -Repository "owner/repo" -PrNumber 123
#
# Note: This is a template script. Actual PR number and repository need to be provided.

param(
    [Parameter(Mandatory=$false)]
    [string]$Repository = "PLACEHOLDER_REPO",
    
    [Parameter(Mandatory=$false)]
    [int]$PrNumber = 0,
    
    [Parameter(Mandatory=$false)]
    [string]$GithubToken = $env:GITHUB_TOKEN
)

# Validate inputs
if ($Repository -eq "PLACEHOLDER_REPO" -or $PrNumber -eq 0) {
    Write-Host "⚠️  Usage: .\github-pr-review.ps1 -Repository <repository> -PrNumber <pr-number>" -ForegroundColor Yellow
    Write-Host "   Example: .\github-pr-review.ps1 -Repository sundgaard-solita/ai-demo -PrNumber 123" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   This script will:"
    Write-Host "   1. Fetch PR details"
    Write-Host "   2. Display PR status"
    Write-Host "   3. Show recent commits"
    Write-Host "   4. Display check runs status"
    exit 1
}

Write-Host "🔍 Fetching PR #$PrNumber from $Repository..." -ForegroundColor Cyan

# Check if GitHub CLI is installed
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghInstalled) {
    Write-Host "❌ GitHub CLI (gh) is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

try {
    # Fetch PR details
    Write-Host ""
    Write-Host "📋 PR Details:" -ForegroundColor Green
    gh pr view $PrNumber --repo $Repository

    Write-Host ""
    Write-Host "✅ PR Checks Status:" -ForegroundColor Green
    gh pr checks $PrNumber --repo $Repository

    Write-Host ""
    Write-Host "📝 Recent Commits:" -ForegroundColor Green
    $commits = gh pr view $PrNumber --repo $Repository --json commits | ConvertFrom-Json
    $commits.commits | Select-Object -Last 5 | ForEach-Object {
        Write-Host "- $($_.commit.message) by $($_.author.login)"
    }

    Write-Host ""
    Write-Host "💬 To review the PR in your browser, run:" -ForegroundColor Cyan
    Write-Host "   gh pr view $PrNumber --repo $Repository --web" -ForegroundColor White

    Write-Host ""
    Write-Host "✅ Script completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error fetching PR details: $_" -ForegroundColor Red
    exit 1
}
