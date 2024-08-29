function Get-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function retrieves information about an admin relationship.

    .DESCRIPTION
    This function retrieves either basic or detailed information about an admin relationship.
    The detailed information retrieves the access assignment information, requests information and operations information.

    .PARAMETER AdminRelationshipId
    This parameter is optional, and information about all the specific admin relationship is retrieved if specified. If the parameter is absent, information about all the admin relationships is retrieved.

    .PARAMETER ExtendedInformation
    This parameter is a switch parameter and decides whether the extended infromation should be retrieved.

    .INPUTS
    The function inputs are all optinal, and are an admin relationship ID and the option to get extended information about each retrieved admin relationship.

    .OUTPUTS
    The function outputs either general information about the admin relationship or every bit of information associated with the admin relationship including the general information, access assignemnts, requests and operations.
    
    If information about a single admin relationship was requested, the output will be a hashtable.
    If information about all the admin relationships was requested, the output will be an array of hashtables.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationship

    .NOTES
    This function first determines whether the admin relationship ID is specified or not.
    If it is not specified, information about all the admin relationships is retrieved.
    The ExtendedInformation switch parameter determines whether extended information should be retrieved.

    If the previous condition for the admin relationship parameter was not met, the admin relationship is definetly specified and information about the admin relationship is returned with the same logic.

    .EXAMPLE
    Get-CMPCAdminRelationship
    This example shows how to retrieve basic information about all the admin relationships.

    .EXAMPLE
    Get-CMPCAdminRelationship -ExtendedInformation
    This example shows how to retrieve all possible information about all the admin relationships.
    Are there many admin relationships, this command will eventually end successfully because the access token is always updated in the background, but it may take many hours time to retrieve all the possible information.

    .EXAMPLE
    Get-CMPCAdminRelationship -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve basic information about a specific admin relationship.

    .EXAMPLE
    Get-CMPCAdminRelationship -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -ExtendedInformation
    This example shows how to retrieve all possible information about a specific admin relationship.
    #>

    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "AllAdminRelationships",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationship")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$AdminRelationshipId,
        
        [Parameter(Mandatory = $false, ParameterSetName = "AdminRelationship")]
        [Parameter(Mandatory = $false, ParameterSetName = "AllAdminRelationships")]
        [System.Management.Automation.SwitchParameter]$ExtendedInformation
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if (!$AdminRelationshipId)
        {
            $adminRelationshipCollection = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"
    
            if ($ExtendedInformation)
            {
                $allAdminRelationships = @()
    
                foreach ($adminRelationshipObject in $adminRelationshipCollection) {
                    $adminRelationship = @{
                        "@" = $adminRelationshipObject
                        accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/accessAssignments"
                        operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/operations"
                        requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/requests"
                    }
                    $allAdminRelationships += $adminRelationship
                }
    
                return $allAdminRelationships
            }
            
            return $adminRelationshipCollection
        }
        else {
            $headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            $adminRelationshipObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)" -Headers $headers
            $adminRelationshipObject.PSObject.Properties.Remove("@odata.context")
    
            if ($ExtendedInformation)
            {
                $adminRelationship = @{
                    "@" = $adminRelationshipObject
                    AccessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments"
                    Operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/operations"
                    Requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/requests"
                }
    
                return $adminRelationship
            }
            
            return $adminRelationshipObject
        }
    }

    end
    {

    }
}
