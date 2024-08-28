function Get-CMPCAdminRelationshipRequests {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function returns information about all the requests on an admin relationship.

    .DESCRIPTION
    This function returns all the requests on an admin relationship.
    Requests include the lock of an admin relationship for approval, a termination of an admin relationship and the edit of an admin relationship.

    .PARAMETER AdminRelationshipId
    This is the ID of the admin relationship that you want to retrieve requests for.

    .INPUTS
    The function takes an admin relationship ID as an input, in the GUID-GUID pattern in string format.

    .OUTPUTS
    The function returns an array with all the found requests, based on the admin relationship ID.
    The function returns an error if the API request to retrieve the requests did not run successfully.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshiprequests

    .NOTES
    The function runs one or more API requests to retrieve all the historic requests on an admin relationship.
    The function then returns an array with all the requests found.

    .EXAMPLE
    Get-CMPCAdminRelationshipRequests -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with all the historic requests on an admin relationship.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshiprequests",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$AdminRelationshipId
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        try {
            $requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/requests"
        }
        catch {
            throw "Could not get the requests from the admin relationship, verify that the provided parameter(s) are correct. Exception: $($_)"
        }
        
        return $requests
    }

    end
    {
        
    }
}
