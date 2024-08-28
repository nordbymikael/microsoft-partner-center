$tenantId = ""
$clientId = ""
$clientSecret = ""

####################################################################################################
# Define the variables above and run the script
####################################################################################################

#Install-Module PartnerCenter
Import-Module PartnerCenter
Import-Module CustomMicrosoftPartnerCenter

Connect-PartnerCenter -Tenant $tenantId -UseDeviceAuthentication
Connect-CMPC -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret

$allPartnerCustomers = Get-PartnerCustomer
$allAdminRelationships = Get-CMPCAdminRelationship
$missingAdminCustomers = @()

foreach ($partnerCustomer in $allPartnerCustomers)
{
    if (($allAdminRelationships | Where-Object {$_.customer.tenantId -eq $partnerCustomer.CustomerId} | Where-Object {$_.status -eq "active"}))
    {
        Continue
    }
    else {
        Write-Output "Found missing customer"
        $missingAdminCustomer = [PSCustomObject]@{
            tenantId = $partnerCustomer.CustomerId
            displayName = $partnerCustomer.Name
        }
        $missingAdminCustomers += $missingAdminCustomer
    }
}

Write-Host -Object $missingAdminCustomers
