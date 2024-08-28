function Remove-CMPCAdminRelationshipAccessAssignment {
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
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.String]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [System.String]$securityGroupId
    )
    #ferdig, må testes
    begin
    {
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    }

    process
    {
        $allAccessAssignments = Get-AllGraphAPIResponses -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
        $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $securityGroupId}
        $headers."If-Match" = $accessAssignment."@odata.etag"

        switch ($accessAssignment.status)
        {
            "active" {
                Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignment.id)" -Headers $headers > $null
                return "Ended the access assignment with the id $($accessAssignmentId) and security group $($securityGroupId), associated with the admin relationship with the id $($adminRelationshipId)."
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
                return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) does not exist."
            }
        }
    }

    end
    {

    }

    <#
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [System.String]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [System.String]$accessAssignmentId
    )
    
    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }

    $accessAssignment = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)?`$select=@odata.etag" -Headers $headers
    $headers."If-Match" = $accessAssignment."@odata.etag"

    switch ($accessAssignment.status)
    {
        "active" {
            Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)" -Headers $headers > $null
            return "Ended the access assignment with the id $($accessAssignmentId), associated with the admin relationship with the id $($adminRelationshipId)."
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
    }
    #>
}
