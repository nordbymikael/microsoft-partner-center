function Confirm-AdminCustomerExistence {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.String]$CustomerTenantId
    )
    
    begin
    {
        Confirm-AccessTokenExistence
        
        $Headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    }

    process
    {
        try {
            Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminCustomers/$($CustomerTenantId)" -Headers $Headers
        }
        catch {
            throw "The specified delegated admin customer does not exist. The customer becomes a delegated admin customer when the customer has at least one active admin relationship."
        }
    }
    
    end
    {
        
    }
}
