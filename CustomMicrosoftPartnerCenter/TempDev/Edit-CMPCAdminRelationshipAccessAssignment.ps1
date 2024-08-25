function Edit-CMPCAdminRelationshipAccessAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [string]$securityGroup,
        [Parameter(Mandatory = $true)] [array]$unifiedRoles
    )
    #ferdig, må testes
    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }
    $allAccessAssignments = Get-AllGraphAPIResponses -accessToken $authTokenManager.GetValidToken() -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments?`$select=@odata.etag,id,status,accessContainer"
    $accessAssignment = $allAccessAssignments | Where-Object {$_.status -eq "active"} | Where-Object {$_.accessContainer.accessContainerId -eq $securityGroup}
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
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $true)] [string]$accessAssignmentId,
        [Parameter(Mandatory = $true)] [array]$unifiedRoles
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
