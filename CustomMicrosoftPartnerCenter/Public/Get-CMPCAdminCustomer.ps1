function Get-CMPCAdminCustomer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $false)] [string]$delegatedAdminCustomerId,
        [Parameter(Mandatory = $false)] [switch]$extendedInformation
    )

    try {
        $headers = @{
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
        }

        if (!$delegatedAdminCustomerId)
        {
            $delegatedAdminCustomers = @()
            $uri = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers"

            if ($extendedInformation)
            {
                do {
                    $delegatedAdminCustomerCollection = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
                    foreach ($delegatedAdminCustomerObject in $delegatedAdminCustomerCollection.value) {
                        $delegatedAdminCustomer = @{
                            "@" = $delegatedAdminCustomerObject
                            serviceManagementDetails = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerObject.id)/serviceManagementDetails" -Headers $headers
                        }
                        $delegatedAdminCustomers += $delegatedAdminCustomer
                    }
                    $uri = $delegatedAdminCustomerCollection."@odata.nextLink"
                } while ($uri)
            }
            else {
                do {
                    $delegatedAdminCustomerCollection = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
                    $delegatedAdminCustomers += $delegatedAdminCustomerCollection.value
                    $uri = $delegatedAdminCustomerCollection."@odata.nextLink"
                } while ($uri)
            }

            return $delegatedAdminCustomers
        }
        else {
            if ($extendedInformation)
            {
                $delegatedAdminCustomer = @{
                    "@" = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerId)" -Headers $headers
                    serviceManagementDetails = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerId)/serviceManagementDetails" -Headers $headers
                }
            }
            else {
                $delegatedAdminCustomer = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($delegatedAdminCustomerId)" -Headers $headers
            }
            
            return $delegatedAdminCustomer
        }
    }
    catch {
        throw "Authorization failed or bad request.`nException: $($_.Exception.Message)"
    }
}
# https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/001ca9bc-9d86-4f2d-ae22-ae2c9b128193/serviceManagementDetails
