function Get-CMPCDelegatedAdminCustomer {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function retrieved either basic or extended information about one or all delegated admin customers.

    .DESCRIPTION
    This function retrieved either basic or extended information about one or all delegated admin customers based on the parameters.

    .PARAMETER CustomerTenantId
    This parameter is the globally unique identifier (GUID) of the customer. It is the tenant ID of the customer.

    .PARAMETER ExtendedInformation
    If this paramter is included, extended information including service management details is retrieved.

    .INPUTS
    This function optionally accepts CustomerTenantId and ExtendedInformation parameters that are strings.

    .OUTPUTS
    The function outputs either general information about the delegated admin customer or every bit of information associated with the delegated admin customer including the service management details.
    
    If information about a single delegated admin customer was requested, the output will be a hashtable.
    If information about all the delegated admin customers was requested, the output will be an array of hashtables.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcdelegatedadmincustomer

    .NOTES
    This function first determines whether the delegated admin customer ID (the customer's tenant ID) is specified or not.
    If it is not specified, information about all the delegated admin customers is retrieved.
    The ExtendedInformation switch parameter determines whether extended information should be retrieved.

    If the previous condition for the delegated admin cusotmer ID parameter was not met, the delegated admin customer is definetly specified and information about the delegated admin customer is returned with the same logic.

    .EXAMPLE
    Get-CMPCDelegatedAdminCustomer
    This example shows how to retrieve basic information about all the delegated admin customers.

    .EXAMPLE
    Get-CMPCDelegatedAdminCustomer -ExtendedInformation
    This example shows how to retrieve 

    .EXAMPLE
    Get-CMPCDelegatedAdminCustomer -CustomerTenantId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve 

    .EXAMPLE
    Get-CMPCDelegatedAdminCustomer -CustomerTenantId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -ExtendedInformation
    This example shows how to retrieve 
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "AllAdminCustomers",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcdelegatedadmincustomer",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "AdminCustomer")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$CustomerTenantId,
        
        [Parameter(Mandatory = $false, ParameterSetName = "AdminCustomer")]
        [Parameter(Mandatory = $false, ParameterSetName = "AllAdminCustomers")]
        [System.Management.Automation.SwitchParameter]$ExtendedInformation
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if (!$CustomerTenantId)
        {
            $DelegatedAdminCustomerCollection = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers"

            if ($ExtendedInformation)
            {
                $DelegatedAdminCustomers = @()

                foreach ($DelegatedAdminCustomerObject in $DelegatedAdminCustomerCollection) {
                    $DelegatedAdminCustomer = @{
                        "@" = $DelegatedAdminCustomerObject
                        ServiceManagementDetails = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($DelegatedAdminCustomerObject.id)/serviceManagementDetails"
                    }
                    $DelegatedAdminCustomers += $DelegatedAdminCustomer
                }

                return $DelegatedAdminCustomers
            }
            
            return $DelegatedAdminCustomerCollection
        }
        else {
            $headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            $DelegatedAdminCustomerObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($CustomerTenantId)" -Headers $headers
            $DelegatedAdminCustomerObject.PSObject.Properties.Remove("@odata.context")
            
            if ($ExtendedInformation)
            {
                $DelegatedAdminCustomer = @{
                    "@" = $DelegatedAdminCustomerObject
                    ServiceManagementDetails = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($CustomerTenantId)/serviceManagementDetails"
                }

                return $DelegatedAdminCustomer
            }
            
            return $DelegatedAdminCustomerObject
        }
    }

    end
    {
        
    }
}
