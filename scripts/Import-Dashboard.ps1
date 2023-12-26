param ( 
      
    [Parameter(Mandatory=$true)][string]$Tenant,
    [Parameter(Mandatory=$true)][string]$APIKey,
    [Parameter(Mandatory=$true)][string]$Object,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )


# TODO: 
#    Error handling 

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

$headers.Add("Authorization", $APIKey)


# Get User ID from the target system 
$response = Invoke-RestMethod "https://${Endpoint}/access-control-svc/v1/tenants/$Tenant/openid-connect/userinfo" -Method 'GET' -Headers $headers
$UserID = $response.sub

$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")

# Read File 
$dashboard = Get-Content "$Object.dashboard.txt" | ConvertFrom-Json

# Fix Dashboard Layout by getting dependent searches
$SavedSearches = get-ChildItem -Path . -Name "$Object.savedsearch.*.txt"

foreach ($i in $SavedSearches) { 
    $SearchID = $i.Substring($i.Length-40,36)
   

    $Search = Get-Content "$i" | ConvertFrom-Json
    $Search.psobject.Properties.Remove('tenantId')
    $Search.psobject.Properties.Remove('id')
    $Search.psobject.Properties.Remove('createdOn')
    $Search.psobject.Properties.Remove('updatedOn')

    $body = $Search | ConvertTo-Json
    $response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions" -Method 'POST' -Headers $headers -Body $body

    # Get new ID 
    $NewSearchID = $response.content.id

    
    Write-host "Saved SearchID [$SearchID] is now [$NewSearchID]"

    # Update new search object in Layout
    $newlayout = $dashboard.layout.Replace($SearchID,$NewSearchID)
    $dashboard.layout = $newlayout
}


# Remove any read-only objects.
$dashboard.psobject.Properties.Remove('tenantId')
$dashboard.psobject.Properties.Remove('id')
$dashboard.psobject.Properties.Remove('createdOn')
$dashboard.psobject.Properties.Remove('updatedOn')

# Update the owner to user who owns the API Key
$dashboard.userId = $UserID


$body = $dashboard | ConvertTo-Json
$response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions" -Method 'POST' -Headers $headers -Body $body
write-host "Importing Dashboard as ID:[$response.content.id]"


