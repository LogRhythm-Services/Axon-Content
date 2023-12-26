
param ( 
      
    [Parameter(Mandatory=$true)][string]$Tenant,
    [Parameter(Mandatory=$true)][string]$APIKey,
    [Parameter(Mandatory=$true)][string]$Object,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    ) 


# TODO: 
#    Error handling 

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", $APIKey)



# Get Object
$response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions/byName?namePattern=$Object" -Method 'GET' -Headers $headers

#Write Object to File
$response.content | ConvertTo-Json | Out-File "$Object.txt"

# Indentify any saved searches 
$layout = $response.content[0].layout
$dataSourceID = $layout | select-String -pattern "dataSourceId" -AllMatches
$matches = $dataSourceID.Matches.Index

foreach ($i in $matches) { 
    # Extract Saved Search IDs from Dashboard layout
    $ContentID = $layout.Substring($i+15,36)
    write-host $ContentID

    # get Search objects and write to file
    $response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions/$ContentID" -Method 'GET' -Headers $headers
    $response.content | ConvertTo-Json | Out-File "$Object.$ContentID.txt"

}









