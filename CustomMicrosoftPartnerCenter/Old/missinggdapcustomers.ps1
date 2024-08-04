Import-Module "$($env:USERPROFILE)\partnercenter-powershell\EvelonPartnerCenterModule\EvelonPartnerCenterModule.psm1"
Connect-PartnerCenter -Tenant "72465188-6db8-4510-ba33-40392d5db724" -UseDeviceAuthentication
$accessToken = Get-GDAPAdminRelationshipAccessToken
$auth = @{
    Authorization = "Bearer $($accessToken)"
}
$allGDAPs = @()
$url = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"
$missingGDAPCustomers = @()
$customers = get-partnercustomer
do {
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $auth
    $allGDAPs += $response.value
    $url = $response.'@odata.nextLink'
} while ($url -ne $null)

foreach ($customer in $customers)
{
    if (($allGDAPs | Where-Object {$_.customer.tenantid -eq $customer.customerid} | Where-Object {$_.status -eq "active"}) -ne $null)
    {
        Continue
    }
    else {
        $missingobj = [PSCustomObject]@{
            TenantId = $customer.CustomerId
            CustomerName = $customer.Name
        }
        $missingGDAPCustomers += $missingobj
    }
}
($missingGDAPCustomers | convertto-json) | out-file -filepath "C:\temp\missinggdap.json"

