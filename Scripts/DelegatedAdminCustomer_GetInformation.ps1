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

if ($extendedInformation)
{
    $delegatedAdminCustomerInformation = Get-CMPCDelegatedAdminCustomer -TenantId $delegatedAdminCustomerTenantId -ExtendedInformation
}
else
{
    $delegatedAdminCustomerInformation = Get-CMPCDelegatedAdminCustomer -TenantId $delegatedAdminCustomerTenantId
}

Write-Host -Object $delegatedAdminCustomerInformation

Disconnect-CMPC
