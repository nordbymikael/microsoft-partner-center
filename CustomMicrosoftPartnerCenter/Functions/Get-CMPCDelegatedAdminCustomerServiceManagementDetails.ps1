function Get-CMPCDelegatedAdminCustomerServiceManagementDetails {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function returns an array with all the service management details on a delegated admin customer.

    .DESCRIPTION
    This function returns an array with all the service management details on a delegated admin customer.
    A delegated admin customer is an existing customer in Partner Center which also has an active admin relationship.
    Customers without active admin relationships are not delegated admin customers.

    The service management details include all the admin portals that are inside the service management tab for the customer in Microsoft Partner Center.
    This function will provide the login links for the customer's admin portals (admin portal URLs including the Tenant ID of the customer).

    .PARAMETER TenantId
    This is the Tenant ID that you want to retrieve service management details for.

    .INPUTS
     The function takes a Tenant ID as an input, in the GUID pattern in string format.

    .OUTPUTS
    The function returns an array with all the found service management details, based on the provided Tenant ID.
    The function returns an error if the API request to retrieve the servoce management details did not run successfully.
    The unsuccessful API request indicates that the provided Tenant ID does not belong to a delegated admin customer.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcdelegatedadmincustomerservicemanagementdetails

    .NOTES
    The function runs one or more API requests to retrieve all the service management details on a customer in Partner Center.
    The function then returns an array with all the service management details found.

    .EXAMPLE
    Get-CMPCDelegatedAdminCustomerServiceManagementDetails -TenantId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with all the service management details on a delegated admin customer.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcdelegatedadmincustomerservicemanagementdetails",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            Confirm-AdminCustomerExistence -CustomerTenantId $_
        })]
        [System.String]$CustomerTenantId
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        try {
            $ServiceManagementDetails = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($CustomerTenantId)/serviceManagementDetails"
        }
        catch {
            throw "Could not get the service management details from the delegated admin customer, verify that the provided Tenant ID is correct. Exception: $($_)"
        }

        return $ServiceManagementDetails
    }

    end
    {

    }
}
