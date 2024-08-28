function Get-CMPCAdminRelationshipAccessAssignment {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function returns information about access assignments on an admin relationship.

    .DESCRIPTION
    If only the admin relationship is specified, you get all the history of access assignments on the admin relationship.
    If the security group ID is specified, you get the full history of the access assignments associated with the specific security group.
    If the access assignment ID is specified, you get the information about a specific access assignment.

    .PARAMETER AdminRelationshipId
    This is the ID of the admin relationship that you want to retrieve an access assignment for.

    .PARAMETER SecurityGroupId
    This is the ID of the security group that an access assignment has been given to in advance.

    .PARAMETER AccessAssignmentId
    Usually, the user does not have any use for this parameter because it is primarily used in the backend by Microsoft.
    When an access assignment is created for a security group on an admin relationship, the access assignment id will be generated with a random globally unique identifier (GUID).
    The historic entry of that specific access assignment will be uniquely identified by the access assignment ID.
    
    The security group can only have one active access assignment at a time.
    Therefore, the creation of a new access assignment on the security group will trigger a 409 error if an active access assignment on the security group already exists.
    To edit an active access assignment, use the Edit-CMPCAdminRelationshipAccessAssignment function.

    .INPUTS
    The function takes an admin relationship ID as an input, in the GUID-GUID pattern in string format.
    The function also takes either a security group ID or an access assignment ID in GUID pattern in string format.

    .OUTPUTS
    The function returns an array with all the found access assignments, based on the parameters.
    The function returns an error if the API request to retrieve the access assignments did not run successfully.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshipaccessassignment

    .NOTES
    Either the default parameter set is used (using only the admin relationship ID), or one of the other parameter sets is used (using either the security group or access assignment ID option).
    Based on the parameter set that is used, the function chooses which API call to run to retrieve one or more access assignments.
    The function then returns an array with all the access assignments that was found.
    An unsuccessful API request will return an error.

    .EXAMPLE
    Get-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with all the historic access assignments on an admin relationship.

    .EXAMPLE
    Get-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -SecurityGroupId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with all the historic access assignments on an admin relationship that are associated with a specific security group.

    .EXAMPLE
    Get-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -AccessAssignmentId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to retrieve an array with the unique access assignment on an admin relationship that is associated with an access assignment ID.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "AdminRelationshipOnly",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipOnly")]
        [Parameter(Mandatory = $true, ParameterSetName = "SecurityGroupId")]
        [Parameter(Mandatory = $true, ParameterSetName = "AccessAssignmentId")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$AdminRelationshipId,

        [Parameter(Mandatory = $true, ParameterSetName = "SecurityGroupId")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$SecurityGroupId,

        [Parameter(Mandatory = $true, ParameterSetName = "AccessAssignmentId")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$AccessAssignmentId
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        try {
            if ($PSCmdlet.ParameterSetName -eq "AdminRelationshipOnly")
            {
                $accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments"
            }
            elseif ($PSCmdlet.ParameterSetName -eq "SecurityGroupId")
            {
                $accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments" | Where-Object {$_.accessContainer.accessContainerId -eq $SecurityGroupId}
            }
            elseif ($PSCmdlet.ParameterSetName -eq "AccessAssignmentId")
            {
                $accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments/$($AccessAssignmentId)"
            }
        }
        catch {
            throw "Could not get the access assignments from the admin relationship, verify that the provided parameter(s) are correct. Exception: $($_)"
        }
        
        return $accessAssignments
    }

    end
    {
        
    }
}
