function Get-CMPCDelegatedAdminCustomer {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    Easy description of the function

    .DESCRIPTION
    Advanced description of the function

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .INPUTS
    Inputs of the function

    .OUTPUTS
    Outputs of the function

    .LINK
    Online version: url

    .NOTES
    Advanced explanation of the code flow

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcdelegatedadmincustomer",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$TenantId,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [System.Management.Automation.SwitchParameter]$ExtendedInformation
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if (!$TenantId)
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
            $DelegatedAdminCustomerObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($TenantId)" -Headers $headers
            $DelegatedAdminCustomerObject.PSObject.Properties.Remove("@odata.context")
            
            if ($ExtendedInformation)
            {
                $DelegatedAdminCustomer = @{
                    "@" = $DelegatedAdminCustomerObject
                    ServiceManagementDetails = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/DelegatedAdminCustomers/$($TenantId)/serviceManagementDetails"
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
