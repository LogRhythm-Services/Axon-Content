#
# Custom Role 
#
param ( 
      
    [Parameter(Mandatory=$true)][string]$Tenant,
    [Parameter(Mandatory=$true)][string]$APIKey,
    [Parameter(Mandatory=$true)][string]$RoleName,
    [Parameter(Mandatory=$true)][string]$Capabilities,
    [string]$Endpoint = "api.na01.prod.boreas.cloud"
    )


    # Auth Header
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Authorization", $APIKey)
    $headers.Add("Content-Type", "application/json")


## 
# Create archetype
## 

# Build Archtype Body 
        
    $body = @"
{
  `"name`": "$RoleName",
  `"capabilities`": [
  
"@


    foreach ($Capability in $Capabilities -split ',')  {

        $body_capability = @"
            { 
            `"tenantID`": `"logrhythm`",
            `"id`": "$Capability"
            }

"@

        $body = $body + $body_capability
        }


  $body = $body + "] }"

     #write-host $body

    $response = Invoke-RestMethod "https://$Endpoint/access-control-svc/v1/tenants/$Tenant/role-archetypes" -Method POST -Headers $headers -Body $body
    $response | ConvertTo-Json

    $archetypeId = $response.content.id



## 
# Create Role
##
# Build Archtype Body 
        
    $body = @"
{
  `"name`": "$RoleName",
  `"roleArchetype`": {
        `"id`": "$archetypeId",
        `"tenantId`": "$Tenant"
        }
} 
"@

    $response = Invoke-RestMethod "https://$Endpoint/access-control-svc/v1/tenants/$Tenant/roles" -Method POST -Headers $headers -Body $body
    $response | ConvertTo-Json

    write-host $response





