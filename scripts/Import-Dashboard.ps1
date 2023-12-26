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
$dashboard = Get-Content "$Object.txt" | ConvertFrom-Json

# Fix Layout
$SavedSearches = get-ChildItem -Path . -Name "$Object.*.txt"

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


# Import Layout 

$dashboard.psobject.Properties.Remove('tenantId')
$dashboard.psobject.Properties.Remove('id')
$dashboard.psobject.Properties.Remove('createdOn')
$dashboard.psobject.Properties.Remove('updatedOn')
$dashboard.userId = $UserID


$body = $dashboard | ConvertTo-Json
$response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions" -Method 'POST' -Headers $headers -Body $body
write-host "Created $response.content.id"


