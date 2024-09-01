[System.String]$TenantId = ""
[System.String]$ClientId = ""
[System.String]$ClientSecret = ""

[System.String]$AdminRelationshipId = ""

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

Remove-CMPCAdminRelationship -AdminRelationshipId $AdminRelationshipId

Disconnect-CMPC
