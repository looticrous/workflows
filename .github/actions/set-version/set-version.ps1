<#
.SYNOPSIS
    Generates a container version based on GitHub Actions context information.

.DESCRIPTION
    This script determines the appropriate version for container images based on how the 
    GitHub Actions workflow was triggered and which branch it's running on. It supports
    three versioning strategies:
    
    1. Manual deployment with custom version tag
    2. Main branch with date-based versioning (YYYY.MM.run_number)
    3. Feature/development branches with semantic versioning (1.0.run_number-branch_name)

.PARAMETER event_name
    The name of the GitHub event that triggered the workflow (e.g., "push", "workflow_dispatch").
.PARAMETER deployment_tag
    The user-specified deployment tag for manual deployments (if any).
.PARAMETER ref_name
    The Git reference name (branch or tag) that triggered the workflow.
.PARAMETER run_number
    The GitHub Actions run number for the current workflow run.

.OUTPUTS
    Writes the generated version to GitHub Actions output and displays it to the host.

.EXAMPLE
    # Manual deployment with custom version
    .\set-version.ps1 -event_name "workflow_dispatch" -deployment_tag "v2025.09.123" -ref_name "main" -run_number "456"
    # Output: Determined version: v2025.09.123
    # Sets GitHub Actions output: version=v2025.09.123

.EXAMPLE
    # Main branch auto-versioning
    .\set-version.ps1 -event_name "push" -deployment_tag "" -ref_name "main" -run_number "789"
    # Output: Determined version: 2025.09.789
    # Sets GitHub Actions output: version=2025.09.789

.EXAMPLE
    # Feature branch versioning
    .\set-version.ps1 -event_name "push" -deployment_tag "" -ref_name "feature/user-auth" -run_number "101"
    # Output: Determined version: 1.0.101-feature-user-auth
    # Sets GitHub Actions output: version=1.0.101-feature-user-auth

.NOTES
    Author: Watco DevOps Team 
    Purpose: Container versioning for GitHub Actions CI/CD pipeline
    Version: 1.0
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$event_name, 
  [Parameter(Mandatory = $false)]
  [string]$deployment_tag, 
  [Parameter(Mandatory = $true)]
  [string]$ref_name,
  [Parameter(Mandatory = $true)]
  [string]$run_number
)


# Determine versioning strategy based on workflow context
if ($event_name -eq 'workflow_dispatch' -and -not [string]::IsNullOrEmpty($deployment_tag)) {
  # Strategy 1: Manual deployment with user-specified version tag
  # Use the exact version provided by the user (e.g., "v2025.09.123")
  $version = $deployment_tag
}
elseif ($ref_name -eq 'main') {
  # Strategy 2: Main branch auto-versioning
  # Generate date-based version: YYYY.MM.run_number (e.g., "2025.09.456")
  $date = Get-Date
  $version = "{0}.{1}" -f $date.ToString("yyyy.MM"), $run_number
}
else {
  # Strategy 3: Feature/development branch versioning
  # Create semantic pre-release version: 1.0.run_number-branch_name
  
  # Sanitize branch name: replace special characters with dashes
  $branchSafe = ($ref_name -replace '[^a-zA-Z0-9]', '-') 

  # Limit branch name to 20 characters to avoid excessively long version strings
  if ($branchSafe.Length -gt 20) {
    $branchSafe = $branchSafe.Substring(0, 20)
  }
  
  # Generate version like "1.0.123-feature-user-auth"
  $version = "1.0.{0}-{1}" -f $run_number, $branchSafe
}

# Output the version for GitHub Actions
Write-Host "Determined version: $version"
"version=$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append