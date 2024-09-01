[System.String]$TenantId = ""
[System.String]$ClientId = ""
[System.String]$ClientSecret = ""

[System.String]$AdminRelationshipId = ""
[System.String]$SecurityGroup = ""
[System.String[]]$UnifiedRoles = "","",""

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

New-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId $AdminRelationshipId -SecurityGroup $SecurityGroup -UnifiedRoles $UnifiedRoles

Disconnect-CMPC
