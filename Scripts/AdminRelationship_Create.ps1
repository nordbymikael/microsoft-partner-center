[System.String]$TenantId = ""
[System.String]$ClientId = ""
[System.String]$ClientSecret = ""

[System.String]$DisplayName = ""
[System.String]$Duration = ""
[System.String[]]$UnifiedRoles = "","",""
[System.String]$AutoExtendDuration = ""

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

New-CMPCAdminRelationship -DisplayName $DisplayName -Duration $Duration -UnifiedRoles $UnifiedRoles -AutoExtendDuration $AutoExtendDuration

Disconnect-CMPC
