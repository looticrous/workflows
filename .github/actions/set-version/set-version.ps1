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

.PARAMETER param1
    A JSON string containing GitHub Actions context information with the following structure:
    {
        "event_name": "workflow_dispatch|push",
        "deployment_tag": "optional custom version",
        "ref_name": "branch name",
        "run_number": "workflow run number"
    }

.OUTPUTS
    JSON object containing the generated version:
    {
        "version": "generated version string"
    }

.EXAMPLE
    # Manual deployment with custom version
    $context = '{"event_name":"workflow_dispatch","deployment_tag":"v2025.09.123","ref_name":"main","run_number":"456"}'
    .\set-container-version.ps1 -param1 $context
    # Returns: {"version": "v2025.09.123"}

.EXAMPLE
    # Main branch auto-versioning
    $context = '{"event_name":"push","deployment_tag":"","ref_name":"main","run_number":"789"}'
    .\set-container-version.ps1 -param1 $context
    # Returns: {"version": "2025.09.789"}

.EXAMPLE
    # Feature branch versioning
    $context = '{"event_name":"push","deployment_tag":"","ref_name":"feature/user-auth","run_number":"101"}'
    .\set-container-version.ps1 -param1 $context
    # Returns: {"version": "1.0.101-feature-user-auth"}

.NOTES
    Author: Watco DevOps Team 
    Purpose: Container versioning for GitHub Actions CI/CD pipeline
    Version: 1.0
#>

[cmdletbinding()]
param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({
      ($_ | ConvertFrom-Json) -ne $null -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'event_name' -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'deployment_tag' -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'ref_name' -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'run_number'
    })]
  [string]
  $param1 
)

# Parse the JSON input parameter
$deserialized = $param1 | ConvertFrom-Json

# Determine versioning strategy based on workflow context
if ($deserialized.event_name -eq 'workflow_dispatch' -and -not [string]::IsNullOrEmpty($deserialized.deployment_tag)) {
  # Strategy 1: Manual deployment with user-specified version tag
  # Use the exact version provided by the user (e.g., "v2025.09.123")
  $version = $deserialized.deployment_tag
}
elseif ($deserialized.ref_name -eq 'main') {
  # Strategy 2: Main branch auto-versioning
  # Generate date-based version: YYYY.MM.run_number (e.g., "2025.09.456")
  $date = Get-Date
  $version = "{0}.{1}" -f $date.ToString("yyyy.MM"), $deserialized.run_number
}
else {
  # Strategy 3: Feature/development branch versioning
  # Create semantic pre-release version: 1.0.run_number-branch_name
  
  # Sanitize branch name: replace special characters with dashes
  $branchSafe = ($deserialized.ref_name -replace '[^a-zA-Z0-9]', '-') 
  
  # Limit branch name to 20 characters to avoid excessively long version strings
  if ($branchSafe.Length -gt 20) {
    $branchSafe = $branchSafe.Substring(0, 20)
  }
  
  # Generate version like "1.0.123-feature-user-auth"
  $version = "1.0.{0}-{1}" -f $deserialized.run_number, $branchSafe
}

# Output the version as JSON for consumption by GitHub Actions workflow
Write-Output $version