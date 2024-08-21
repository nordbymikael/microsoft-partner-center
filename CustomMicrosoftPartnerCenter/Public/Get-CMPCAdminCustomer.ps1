function Get-CMPCAdminCustomer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $false)] [string]$delegatedAdminCustomerId,
        [Parameter(Mandatory = $false)] [switch]$extendedInformation
    )

    if (!$delegatedAdminCustomerId)
    {
        $uri = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers"

        if ($extendedInformation)
        {
            $delegatedAdminCustomerCollection = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri $uri
            $delegatedAdminCustomers = @()

            foreach ($delegatedAdminCustomerObject in $delegatedAdminCustomerCollection) {
                $delegatedAdminCustomer = @{
                    "@" = $delegatedAdminCustomerObject
                    serviceManagementDetails = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerObject.id)/serviceManagementDetails"
                }
                $delegatedAdminCustomers += $delegatedAdminCustomer
            }
        }
        else {
            $delegatedAdminCustomers = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri $uri
        }

        return $delegatedAdminCustomers
    }
    else {
        $headers = @{
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
        }
        $delegatedAdminCustomerObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerId)" -Headers $headers
        $delegatedAdminCustomerObject.PSObject.Properties.Remove("@odata.context")
        
        if ($extendedInformation)
        {
            $delegatedAdminCustomer = @{
                "@" = $delegatedAdminCustomerObject
                serviceManagementDetails = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerId)/serviceManagementDetails"
            }
        }
        else {
            $delegatedAdminCustomer = $delegatedAdminCustomerObject
        }
        
        return $delegatedAdminCustomer
    }
}
