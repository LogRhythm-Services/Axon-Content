##################################################################################################################################################
# Description: Powershell Script to Export Axon Case Evidence
# This script will grab all associated case evidence, ledger details, and case overview from a requested Axon case number
# 
# Created by: Brandon Pace - LogRhythm Principal Territory Sales Engineer (5/16/2024)          
# 
# PS C:\Tools> .\AxonCaseEvidenceExport.ps1 >$null
# Axon Case Information Export - Please Enter Case Number: 22991
# Case Export Completed for 22991
# Filename: c:\Temp\CaseExport\LogRhythm_Axon_Case_22991_Export.txt
#
# To use the script
#
# Enter your API in the headers: <YOURAPIKEY>
# Set your TenantID: $tenantid = "demo"
# Modify your path: $CaseFile = "c:\Temp\CaseExport\LogRhythm_Axon_Case_${CaseNumber}_Export.txt"  
##################################################################################################################################################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "<YOURAPIKEY>")
$CaseNumber = Read-Host "Axon Case Information Export - Please Enter Case Number"
$tenantid = "demo"
$uri = "https://api.na01.prod.boreas.cloud/case-management-svc/v1/tenants/${tenantid}/cases/byNumber/$CaseNumber"

$response = Invoke-RestMethod -Uri $uri -Method 'GET' -Headers $headers
#Create the base directory first
$CaseFile = "c:\Temp\CaseExport\LogRhythm_Axon_Case_${CaseNumber}_Export.txt"

$header1 = "`r`n============================================================================================================`r`nCase Information for LogRhythm Axon Case ${CaseNumber}`r`n============================================================================================================`r`n"
$header1 | Out-File -FilePath $CaseFile
$response.content | ConvertTo-Json | ConvertFrom-Json | Out-File -FilePath $CaseFile -Append
$CaseID = $response.content."id"


$uri2 = "https://api.na01.prod.boreas.cloud/case-management-svc/v1/tenants/${tenantid}/activities/byCaseId/$CaseID"

$CaseActivityResponse = Invoke-RestMethod -Uri $uri2 -Method 'GET' -Headers $headers
$header2 = "`r`n============================================================================================================`r`nCASE ACTIVITY DETAILS/LEDGER for LogRhythm Axon Case ${CaseNumber}`r`n============================================================================================================`r`n"
$header2 | Add-Content -Path $CaseFile
$CaseActivityResponse.content | ConvertTo-Json | ConvertFrom-Json | Out-File -FilePath $CaseFile -Append
#Set TTL of the tenant.  90 or 400 Days
#Logs within the TTL will be returned if tied to a case
$TTL = "90"

$uri3 = "https://api.na01.prod.boreas.cloud/search-indexing-svc/v1/tenants/${tenantid}/signals"
$evidenceHeader = "`r`n============================================================================================================`r`nCASE EVIDENCE for LogRhythm Axon Case ${CaseNumber}`r`n============================================================================================================`r`n"
$evidenceHeader | Out-File -FilePath $CaseFile -Append
foreach ($record in $CaseActivityResponse.content) {
	if ($record.type -eq "LOG") {
        $recordid=$record.id
		$body = @"
{
		`"filter`": `"general_information.case_activity_id=$recordid`",
		`"time`": {
			`"lrDateTime`": `"now-${TTL}d`",
			`"field`": `"system.create.date`"
	},
    `"pageRequest`": {
        `"limit`": 100
    }
}
"@
	$drilldown = Invoke-RestMethod -Uri $uri3 -Method 'POST' -Headers $headers -Body $body
	$header5 = "`r`n======================================================`r`nCase Activity ID          : $recordid  `r`nAssociated Axon Query     : general_information.case_activity_id = `"${recordid}`" and general_information.standard_message_time = now-${TTL}d`r`n======================================================`r`n"
	$header5 | Out-File -FilePath $CaseFile -Append		
    $drilldown | ConvertTo-Json 
	
	
	if ($drilldown.content.result."action.type" -eq "observation") {
		
		$header4 = "`r`n==============================`r`nAnalytics Observation`r`n==============================`r`n"
		$header4 | Out-File -FilePath $CaseFile -Append
		"Analytics Rule Name    : " + $drilldown.content.result."object.policy.name" | Out-File -FilePath $CaseFile -Append
		"Threat Name            : " + $drilldown.content.result."threat.name" | Out-File -FilePath $CaseFile -Append
		"Threat Description     : " + $drilldown.content.result."threat.description" | Out-File -FilePath $CaseFile -Append
		"Threat Subcategory     : " + $drilldown.content.result."threat.subcategory" | Out-File -FilePath $CaseFile -Append
		"Threat Category        : " + $drilldown.content.result."threat.category" | Out-File -FilePath $CaseFile -Append
		"Threat Description     : " + $drilldown.content.result."threat.description" | Out-File -FilePath $CaseFile -Append
		"Threat Evidence        : " + $drilldown.content.result."threat.evidence" | Out-File -FilePath $CaseFile -Append
		"Threat ID              : " + $drilldown.content.result."threat.id" | Out-File -FilePath $CaseFile -Append
		"MITRE ATT&CK Tactic    : " + $drilldown.content.result."threat.mitre_tactic" | Out-File -FilePath $CaseFile -Append
		"Raw Observation        : " + $drilldown.content.result."action.observation.json" | ConvertTo-Json | ConvertFrom-Json | Out-File -FilePath $CaseFile -Append}
	$header5 = "`r`n==============================`r`nRaw Log Message(s)`r`n==============================`r`n"
	$header5 | Out-File -FilePath $CaseFile -Append
	$drilldown.content.result."general_information.raw_message" | Add-Content -Path $CaseFile
	
    				
}

}	

Write-Host "Case Export Completed for $CaseNumber"
Write-Host "Filename: $CaseFile" 