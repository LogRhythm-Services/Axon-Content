#
# Powershell script to pull a list from Axon of installed agents and deliver that output in JSON and CSV
# Script born from selectively cannibalized work from Jake Haldeman's and Vaughn Adams' scripts
# Rob Haller, Version 0.7, 9/20/2023
#
# Usage - AxonAgentExport -tenantid '<tenant name>' -apikey '<uuidkey>'
# 476 simple lines of powershell -Eric Hart

param ( 
      
    [Parameter(Mandatory=$true)][string]$tenantid,
    [Parameter(Mandatory=$true)][string]$apikey,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )

#Configure headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", $apikey)

#Get Agent List from Axon
$response = Invoke-RestMethod "https://$Endpoint/topology-svc/v1/tenants/$tenantid/agents/byStatus?limit=1200&activeOrRetired=active&profileName=" -Method GET -Headers $headers

#Define the path to save the JSON file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$jsonFilePath = Join-Path -Path $scriptDir -ChildPath "agentlist.json"

#Convert the PowerShell object to JSON and export it
$jsonData = $response.Content | ConvertTo-Json
$jsonData | Out-File -FilePath $jsonFilePath -Encoding UTF8

#Define the path to save the converted JSON to CSV file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csvFilePath = Join-Path -Path $scriptDir -ChildPath "agentlist.csv"

$objects = $jsonData | ConvertFrom-Json  
$objects | ConvertTo-CSV -NoTypeInformation | Set-Content -path $csvFilePath -Encoding UTF8