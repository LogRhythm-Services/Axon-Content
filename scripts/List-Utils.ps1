#
# 
# List Utility Script
#
param ( 
      
    [Parameter(Mandatory=$false)][string]$Tenant,
    [Parameter(Mandatory=$false)][string]$APIKey,
    [Parameter(Mandatory=$false)][string]$ListName,
    [Parameter(Mandatory=$false)][string]$ListId,
    [Parameter(Mandatory=$false)][string]$Action,
    [Parameter(Mandatory=$false)][string]$FileName,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )

    

# Auth Header
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Authorization", $APIKey)

##
# Create List 
##
if ( $Action -eq "Create-List") { 

   if (! $ListName ) { 
        write-host "This option requires the -ListName parameter."
        exit
        }

    #Configure 
    $headers.Add("Content-Type", "application/json")
 

    $body = @"
{
  `"columns`": [
    {
      `"title`": `"Col1`",
      `"type`": `"IP`",
      `"description`": `"These IPs are flagged`"
    }
  ],
  `"description`": `"These IPs are real bad`",
  `"title`": `"$ListName`",
  `"dataStrategy`": `"LOCAL`"
}
"@

    #Write-Host @body

    # Append is a POST, Replace is a PUT

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions" -Method POST -Headers $headers -Body $body
    #$response | ConvertTo-Json
}



##
#  Replace List with a File 
##
if ( $Action -eq "Replace-List") { 

   if (! $ListId ) { 
        write-host "This option requires the -ListID parameter."
        exit
        }

    #Configure 
    $headers.Add("Content-Type", "text/plain")
    $headers.Add("Type","formdata")
    $body =  [IO.File]::ReadAllBytes($FileName);

    # Append is a POST, Replace is a PUT

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v2/tenants/$Tenant/list-definitions/$ListId/list-items/import?headersNotIncluded=true" -Method PUT -Headers $headers -Body $body
    #$response | ConvertTo-Json
}

##
#  Append List with a File 
##
if ( $Action -eq "Append-List") { 

    if (! $ListId ) { 
        write-host "This option requires the -ListID parameter."
        exit
        }

    #Configure 
    $headers.Add("Content-Type", "text/plain")
    $headers.Add("Type","formdata")
    $body =  [IO.File]::ReadAllBytes($FileName);
  
    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v2/tenants/$Tenant/list-definitions/$ListId/list-items/import?headersNotIncluded=true" -Method POST -Headers $headers -Body $body
    #$response | ConvertTo-Json
}

## 
#   Get List Details 
##
if ( $Action -eq "Get-List") { 
    Write-Host "Retrieving list $ListName $ListId" 

   $AfterId="" 

   do { 

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions?limit=100$AfterId" -Method 'GET' -Headers $headers 

    foreach ($i in $response.content) { 
        if ($i.title -eq $ListName) { 
           $ListId = $i.id
           break;
           }
        if ($i.id -eq $ListId) { 
            $ListName = $i.title
            break;
            }
            
        }
   
    $AfterId = "&afterId=$($response.paginationInfo.nextPage)"
    
    } while ( $response.paginationInfo.nextPage )
    
    Write-Host "ListName:[$ListName] GUID:[$ListId]"
}


##
# Get All Lists 
##
if ( $Action -eq "Get-All") { 
   Write-Host "Retrieving all lists" 

   $AfterId="" 

   do { 

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions?limit=100$AfterId" -Method 'GET' -Headers $headers 

    foreach ($i in $response.content) { 
         Write-Host $i.title $i.id
        }
   
    $AfterId = "&afterId=$($response.paginationInfo.nextPage)"
    
    } while ( $response.paginationInfo.nextPage )
    
}


## 
# Delete List 
##
if ( $Action -eq "Delete-List") { 

    if (! $ListId ) { 
        write-host "This option requires the -ListID parameter."
        exit
        }

   $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions/$ListId" -Method 'GET' -Headers $headers 

    Write-Host "Deleting List:" $response.content[0].title

    $response = Invoke-RestMethod "https://$Endpoint/list-svc/v1/tenants/$Tenant/list-definitions/$ListId" -Method 'DELETE' -Headers $headers 
  
}