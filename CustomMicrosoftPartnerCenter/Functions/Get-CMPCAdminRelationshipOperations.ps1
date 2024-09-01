function Get-CMPCAdminRelationshipOperations {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function returns information about all the operations on an admin relationship.

    .DESCRIPTION
    This function returns all the operations on an admin relationship.
    Operations include long-running operations as the removal of a Global Administrator role from the admin relationship.

    .PARAMETER AdminRelationshipId
    This is the ID of the admin relationship that you want to retrieve operations for.

    .INPUTS
    The function takes an admin relationship ID as an input, in the GUID-GUID pattern in string format.

    .OUTPUTS
    The function returns an array with all the found operations, based on the admin relationship ID.
    The function returns an error if the API request to retrieve the operations did not run successfully.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshipoperations

    .NOTES
    The function runs one or more API requests to retrieve all the historic operations on an admin relationship.
    The function then returns an array with all the operations found.

    .EXAMPLE
    Get-CMPCAdminRelationshipOperations -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with all the historic operations on an admin relationship.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshipoperations",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$AdminRelationshipId
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        try {
            $operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/operations"
        }
        catch {
            throw "Could not get the operations from the admin relationship, verify that the provided parameter(s) are correct. Exception: $($_)"
        }
        
        return $operations
    }

    end
    {
        
    }
}
