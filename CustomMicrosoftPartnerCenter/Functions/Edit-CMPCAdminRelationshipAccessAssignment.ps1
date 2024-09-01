function Edit-CMPCAdminRelationshipAccessAssignment {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function replaces an existing access assignment with the roles you specify.

    .DESCRIPTION
    This function edits an existing access assignment by replacing the unified roles in the existing access assignment with the roles you specify.

    .PARAMETER AdminRelationshipId
    Specify the admin relationship ID of the admin relationship that you want to edit an active access assignment on.

    .PARAMETER SecurityGroup
    Specify the security group that you want to edit an active access assignment for.

    .PARAMETER AccessAssignmentId
    If you know the access assignment ID of an active access assignment on a security group, you can specify the access assignment ID instead of the security group ID.

    .PARAMETER UnifiedRoles
    This is an array of strings with the roles that you want to replace the existing access assignment with.

    .INPUTS
    This function accepts an admin relationship ID and a list of roles (unified roles) as input.
    Then, either the security group ID or the access assignment ID has to be specified.

    .OUTPUTS
    This function outputs whether the access assignment edit was successful or not.
    A string is written in the terminal if the operation was successful, and an error is thrown if not.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#edit-cmpcadminrelationshipaccessassignment

    .NOTES
    This function accepts some parameters and validates their formatting and validity.
    The access assignment should be active to edit it, so this is also checked.

    After, the etag is retrieved and added to the header to edit the access assignment later.

    After, the access assignment status goes through a switch statement.
    An active access assignment will be replaced with the specified unified roles.

    .EXAMPLE
    Edit-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -SecurityGroup "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -UnifiedRoles "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to edit an access assignment using the security group as a parameter.

    .EXAMPLE
    Edit-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -AccessAssignmentId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -UnifiedRoles "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to edit an access assignment using the access assignment ID as a parameter.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "AccessAssignmentId",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#edit-cmpcadminrelationshipaccessassignment",
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
        [System.String]$accessAssignmentId,

        [Parameter(Mandatory = $true, ParameterSetName = "SecurityGroup")]
        [Parameter(Mandatory = $true, ParameterSetName = "AccessAssignmentId")]
        [ValidateCount(1, 73)]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            $UnifiedRoles = $_

            Confirm-AccessTokenExistence

            $Headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            
            $AdminRelationshipAccessDetails = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)?`$select=accessDetails" -Headers $Headers

            foreach ($role in $UnifiedRoles) {
                if ($role -notin $AdminRelationshipAccessDetails.accessDetails.unifiedRoles.roleDefinitionId)
                {
                    throw "The role `"$($role)`" in the UnifiedRoles parameter is not a valid role for the specified admin relationship. Remove the role and try again."
                }
                else {
                    $true
                }
            }
        })]
        [System.String[]]$UnifiedRoles
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
        
        if ($PSCmdlet.ParameterSetName -eq "AccessAssignmentId")
        {
            $accessAssignment = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)" -Headers $headers
        }
        elseif ($PSCmdlet.ParameterSetName -eq "SecurityGroup")
        {
            $allAccessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
            $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $SecurityGroup}
            $accessAssignmentId = $accessAssignment.id
        }
    
        $headers."If-Match" = $accessAssignment."@odata.etag"
        $body = @{
            accessDetails = @{
                unifiedRoles = @()
            }
        }

        foreach ($role in $UnifiedRoles)
        {
            $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role}
        }

        switch ($accessAssignment.status)
        {
            "active" {
                Invoke-RestMethod -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignment.id)" -Headers $headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json" > $null
                return "Updated the access assignment with the id $($accessAssignmentId) on the admin relationship with the id $($adminRelationshipId)."
            }
            "pending" {
                return "Failed to update the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is still in the creation status. Wait a few seconds and try again."
            }
            "deleting" {
                return "Failed to update the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is in the deletion process."
            }
            "deleted" {
                return "Failed to update the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is deleted."
            }
            default {
                throw "An unexpected error occurred: $($_)"
            }
        }
    }

    end
    {

    }
}
