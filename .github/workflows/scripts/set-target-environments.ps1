[cmdletbinding()]
param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({
      ($_ | ConvertFrom-Json) -ne $null -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'event_name' -and 
      ($_ | ConvertFrom-Json).PSObject.Properties.Name -contains 'target_environments'
    })]
  [string]
  $param1 
)

$in = $param1 | ConvertFrom-Json
if ($in.event_name -eq 'workflow_dispatch') {
  $environments = $in.target_environments
}
else {
  $environments = @("Development", "QA", "UAT") 
}
Write-Output ($environments | ConvertTo-Json -Compress)