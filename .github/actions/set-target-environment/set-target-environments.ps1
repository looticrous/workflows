[cmdletbinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]$event_name, 
  [Parameter(Mandatory = $false)]
  [string]$target_environments
)

if ($event_name -eq 'workflow_dispatch') {
  $environments = $target_environments.Split(",") | ForEach-Object { $_.Trim() }
}
else {
  $environments = @("Development", "QA", "UAT") 
}
"target_environments=$($environments -join ',')" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append