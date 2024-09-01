[System.String]$TenantId = ""
[System.String]$ClientId = ""
[System.String]$ClientSecret = ""



####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

$AllAdminRelationships = Get-CMPCAdminRelationship
$LegacyMLTAdminRelationships = $AllAdminRelationships | Where-Object {$_.displayName.StartsWith("MLT_")} | Where-Object {$_.status -notin "terminated","terminationRequested","terminating"}

Write-Host -Object "Active, created and pending approval Legacy MLT admin relationships:`n"
$LegacyMLTAdminRelationships

Disconnect-CMPC
