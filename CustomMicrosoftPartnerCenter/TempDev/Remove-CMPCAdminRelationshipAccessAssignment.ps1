function Remove-CMPCAdminRelationshipAccessAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [string]$securityGroup
    )
    #ferdig, må testes
    $headers = @{
        Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
    }

    $allAccessAssignments = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
    $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $securityGroup}
    $headers["If-Match"] = $accessAssignment."@odata.etag"

    switch ($accessAssignment.status)
    {
        "active" {
            Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignment.id)" -Headers $headers > $null
            return "Ended the access assignment with the id $($accessAssignmentId), associated with the admin relationship with the id $($adminRelationshipId)."
        }
        "pending" {
            return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is still in the creation status. Wait a few seconds and try again."
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
    
    <#
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [string]$accessAssignmentId
    )
    
    $headers = @{
        Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
    }

    $accessAssignment = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)?`$select=@odata.etag" -Headers $headers
    $headers["If-Match"] = $accessAssignment."@odata.etag"

    switch ($accessAssignment.status)
    {
        "active" {
            Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments/$($accessAssignmentId)" -Headers $headers > $null
            return "Ended the access assignment with the id $($accessAssignmentId), associated with the admin relationship with the id $($adminRelationshipId)."
        }
        "pending" {
            return "Failed to delete the access assignment. The access assignment with id $($accessAssignmentId) on admin relationship with id $($adminRelationshipId) is still in the creation status. Wait a few seconds and try again."
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
