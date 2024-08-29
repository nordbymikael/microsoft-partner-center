[System.String]$tenantId = ""
[System.String]$clientId = ""
[System.String]$clientSecret = ""

[System.String]$delegatedAdminCustomerTenantId = ""
[System.Boolean]$extendedInformation = $true

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret

$delegatedAdminCustomerInformation = Get-CMPCDelegatedAdminCustomer -CustomerTenantId $delegatedAdminCustomerTenantId -ExtendedInformation:$extendedInformation

Write-Host -Object $delegatedAdminCustomerInformation

Disconnect-CMPC
