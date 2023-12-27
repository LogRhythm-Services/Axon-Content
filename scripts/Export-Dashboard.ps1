
param ( 
      
    [Parameter(Mandatory=$true)][string]$Tenant,
    [Parameter(Mandatory=$true)][string]$APIKey,
    [Parameter(Mandatory=$true)][string]$Object,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    # api.k8s.development.boreas.cloud, api.na01.prod.boreas.cloud
    ) 


# TODO: 
#    Error handling 
#  Check to see if the file exists before clobbering an export.
    

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", $APIKey)



# Get Object
$response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions/byName?namePattern=$Object" -Method 'GET' -Headers $headers 

# Convert to a system object.  There is probably a better way to do this.  
$dashboard = $response.content | ConvertTo-Json | ConvertFrom-Json

# Redact the original tenant name and userID
$dashboard.psobject.Properties.Remove('tenantId')
$dashboard.userID = "0"


#Write Object to File
write-host "Writing dashboard $Object.dashboard.txt"
$dashboard | ConvertTo-Json | Out-File "$Object.dashboard.txt"

# Identify any saved searches in the layouy
$layout = $response.content[0].layout
$dataSourceID = $layout | select-String -pattern "dataSourceId" -AllMatches
$matches = $dataSourceID.Matches.Index

foreach ($i in $matches) { 
    # Extract Saved Search IDs from Dashboard layout
    $ContentID = $layout.Substring($i+15,36)
    write-host "Writing saved search - $ContentID"

    # get Search objects and write to file
    $response = Invoke-RestMethod "https://${Endpoint}/layout-definition-svc/v1/tenants/$Tenant/layoutdefinitions/$ContentID" -Method 'GET' -Headers $headers

    # Convert to a system object.  There is probably a better way to do this.  
    $search = $response.content | ConvertTo-Json | ConvertFrom-Json

    # Redact the original tenant name and userID
    $search.psobject.Properties.Remove('tenantId')
    $search.userID = "0"

    $search | ConvertTo-Json | Out-File "$Object.savedsearch.$ContentID.txt"

}









