function Edit-CMPCAdminRelationshipAccessAssignment {
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
        ConfirmImpact = "High",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#edit-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.String]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [System.String]$securityGroupId,
        [Parameter(Mandatory = $true)] [ValidateCount(1, 72)] [System.Object[]]$unifiedRoles
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {

    }

    end
    {

    }
    
    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }
    $allAccessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
    $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $securityGroupId}
    $headers."If-Match" = $accessAssignment."@odata.etag"
    $body = @{
        accessDetails = @{
            unifiedRoles = $unifiedRoles
        }
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
    }
    
    <#
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [System.String]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [System.String]$accessAssignmentId,
        [Parameter(Mandatory = $true)] [System.Object[]]$unifiedRoles
    )
    
    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }

    $accessAssignment = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)" -Headers $headers
    $headers."If-Match" = $accessAssignment."@odata.etag"
    $body = @{
        accessDetails = @{
            unifiedRoles = $unifiedRoles
        }
    }

    switch ($accessAssignment.status)
    {
        "active" {
            Invoke-RestMethod -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)" -Headers $headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json" > $null
            return "Updated the access assignment with the id $($accessAssignmentId), associated with the admin relationship with the id $($adminRelationshipId)."
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
    }
    #>
}
