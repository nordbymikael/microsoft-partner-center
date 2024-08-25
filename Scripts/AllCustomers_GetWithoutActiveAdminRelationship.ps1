$tenantId = "72465188-6db8-4510-ba33-40392d5db724"
$clientId = "56fe70e2-69c1-41a3-80b9-66912b0a4a76"
$clientSecret = "GZk8Q~RaZvYbdQLUfaejuqE40vQc8aODbi7qwcvh"

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

Write-Output -InputObject $missingAdminCustomers
