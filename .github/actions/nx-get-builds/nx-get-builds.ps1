[cmdletbinding()]
param (
  [Parameter(Mandatory = $false)] 
  [string]
  $projects, 
  [Parameter(Mandatory = $true)]
  [string]
  $base_ref
)

if (-not [string]::IsNullOrEmpty($projects)) {
  Write-Host "Using provided projects: $projects)"
}
else {
  Write-Host "Using nx affected with base: $base_ref"
  $projects = (npx nx affected --target=container --base=$base_ref --plain) -split "`n"
}
"builds=$($projects -join ',')" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append2