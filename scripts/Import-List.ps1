#
# Powershell script to push a list CSV into LogRhythm Axon lists. This is configured to append IPs to a list.
# Script originally cannibalized from Jake Haldeman's and Vaughn Adams' work on this and other collective projects.
# Version 0.5
#

param ( 
      
    [Parameter(Mandatory=$true)][string]$Tenant,
    [Parameter(Mandatory=$true)][string]$APIKey,
    [Parameter(Mandatory=$true)][string]$Object,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )



#Configure headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "text/plain")
$headers.Add("Authorization", $APIKey)
$headers.Add("Type","formdata")
$body =  [IO.File]::ReadAllBytes($Object);


# Append is a POST, Replace is a PUT

#Send CSV to Axon
$response = Invoke-RestMethod "https://$Endpoint/list-svc/v2/tenants/$tenant_id/list-definitions/$list_id/list-items/import?headersNotIncluded=true" -Method POST -Headers $headers -Body $body
$response | ConvertTo-Json