function Get-CMPCAdminRelationship {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId
    )

    try {
        $headers @{
            Authorization = "Bearer $($accessToken)"
        }
        $adminRelationship = @{
            "@" = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
            AccessAssignments = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Headers $headers
            Operations = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/operations" -Headers $headers
            Requests = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests" -Headers $headers
        }
    
        return $adminRelationship
    }
    catch {
        throw "Authorization failed.`nException: $($_.Exception.Message)"
    }
}
