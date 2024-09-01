[System.String]$TenantId = ""
[System.String]$ClientId = ""
[System.String]$ClientSecret = ""

[System.String]$delegatedAdminCustomerTenantId = ""
[System.Boolean]$extendedInformation = $true

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

$delegatedAdminCustomerInformation = Get-CMPCDelegatedAdminCustomer -CustomerTenantId $delegatedAdminCustomerTenantId -ExtendedInformation:$extendedInformation

Write-Host -Object $delegatedAdminCustomerInformation

Disconnect-CMPC
