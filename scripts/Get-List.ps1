param ( 
      
    [Parameter(Mandatory=$false)][string]$Tenant,
    [Parameter(Mandatory=$false)][string]$APIKey,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )
Start-Transcript -Path .\$Tenant.txt 
    
    # Auth Header
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Authorization", $APIKey)

    $AfterId="" 

   do { 

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions?limit=100$AfterId" -Method 'GET' -Headers $headers 

    foreach ($i in $response.content) { 
        $myList = $i.id
        $myColumn = $i.columns.id
        if ($i.entryCount -ne 0)
        {
         Write-Host $i.title "," $i.columns.title
         $Values = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions/$myList/column-definitions/$myColumn/values?limit=10000" -Method 'GET' -Headers $headers
         foreach ($entry in $Values.content) {
            Write-Host $entry.value
         }
            Write-Host "-------"
        }     
        }
   
    $AfterId = "&afterId=$($response.paginationInfo.nextPage)"
    
    } while ( $response.paginationInfo.nextPage )
    Stop-Transcript