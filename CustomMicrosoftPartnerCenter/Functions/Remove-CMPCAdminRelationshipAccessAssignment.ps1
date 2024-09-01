function Remove-CMPCAdminRelationshipAccessAssignment {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function ends an access assignment.

    .DESCRIPTION
    This function validates that the requested access assignment is an active access assignment and ends the access assignment.
    You can specify either the security group that has an active access assignment or the access assignment ID.

    .PARAMETER AdminRelationshipId
    Specify the admin relationship on which you want to remove an access assignment.

    .PARAMETER SecurityGroup
    Specify the security group that has an active access assignment that you want to end.

    .PARAMETER AccessAssignmentId
    Specify the access assignment ID that has an active status and that you want to end.

    .INPUTS
    This function accepts the admin relationship ID as an input.
    Also, either a security group or access assignment ID is accepted as input.

    .OUTPUTS
    The function will either fail and throw an error, or run successfully and output a string.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationshipaccessassignment

    .NOTES
    This function starts to validate the parameters.
    This includes a validation that the access assignments are still active and that this function will indeed have an impact on the access assignment.
    
    Afterwards, the function retrieves the etag and status of the access assignment and adds the etag to the request header to end the access assignment later.
    A switch statement is going through the possible statuses and the function ends the access assignment if the access assignment is active.

    .EXAMPLE
    Remove-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -SecurityGroup "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to end an access assignment based on the security group ID.

    .EXAMPLE
    Remove-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -AccessAssignmentId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to end an access assignment based on the access assignment ID.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "AccessAssignmentId",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "SecurityGroup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "AccessAssignmentId", ValueFromPipeline = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$adminRelationshipId,

        [Parameter(Mandatory = $true, ParameterSetName = "SecurityGroup")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            $SecurityGroup = $_
            $allAccessAssignments = Get-AllGraphAPIResponses -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
            $accessAssignmentId = ($allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $SecurityGroup}).id

            if ($null -eq $accessAssignmentId)
            {
                throw "There are no active access assignments on the security group you specified."
            }
        })]
        [System.String]$SecurityGroup,

        [Parameter(Mandatory = $true, ParameterSetName = "AccessAssignmentId")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            try {
                Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($_)"
            }
            catch {
                throw "The specified access assignment does not exist."
            }
        })]
        [System.String]$accessAssignmentId
    )
    
    begin
    {
        
    }

    process
    {
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }

        if ($PSCmdlet.ParameterSetName -eq "SecurityGroup") {
            $allAccessAssignments = Get-AllGraphAPIResponses -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
            $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $SecurityGroup}
            $accessAssignmentId = $accessAssignment.id
        }
        elseif ($PSCmdlet.ParameterSetName -eq "AccessAssignmentId")
        {
            $accessAssignment = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)?`$select=@odata.etag" -Headers $headers
        }

        $headers."If-Match" = $accessAssignment."@odata.etag"

        switch ($accessAssignment.status)
        {
            "active" {
                Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignment.id)" -Headers $headers > $null
                return "Ended the access assignment with the id $($accessAssignmentId) and security group $($SecurityGroup), associated with the admin relationship with the id $($adminRelationshipId)."
            }
            "pending" {
                return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is still in the creation state. Wait a few seconds and try again."
            }
            "deleting" {
                return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is already in the deletion process."
            }
            "deleted" {
                return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is already deleted."
            }
            default {
                throw "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) does not exist."
            }
        }
    }

    end
    {

    }
}
