# we should expect serialized json input and output from scripts we call in github actions 
[cmdletbinding()] 
param(
  [string] $serialized_parameter1 
)
$deserialized = $serialized_parameter1 | ConvertFrom-Json
$param1 = $deserialized.param1
$param2 = $deserialized.param2
$param3 = $deserialized.param3
Write-Host "Hi there! I'm the WIP script. I work in progress."
Write-Host "These are my parameters:" 
Write-Host "param1: $param1"
Write-Host "param2: $param2"
Write-Host "param3: $param3"
# return results as serialized json
Write-Output @($param1, $param2, $param3) | ConvertTo-Json -Compress
