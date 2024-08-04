function Get-CMPCAdminRelationship {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $false)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [switch]$extendedInformation
    )

    try {
        $headers = @{
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
        }

        if (!$adminRelationshipId)
        {
            $allAdminRelationships = @()
            $uri = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"

            if ($extendedInformation)
            {
                do {
                    $adminRelationshipCollection = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
                    foreach ($adminRelationshipObject in $adminRelationshipCollection.value) {
                        $adminRelationship = @{
                            "@" = $adminRelationshipObject
                            accessAssignments = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/accessAssignments" -Headers $headers
                            operations = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/operations" -Headers $headers
                            requests = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/requests" -Headers $headers
                        }
                        $allAdminRelationships += $adminRelationship
                    }
                    $uri = $adminRelationshipCollection."@odata.nextLink"
                } while ($uri)
            }
            else {
                do {
                    $adminRelationshipCollection = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
                    $allAdminRelationships += $adminRelationshipCollection.value
                    $uri = $adminRelationshipCollection."@odata.nextLink"
                } while ($uri)
            }

            return $allAdminRelationships
        }
        else {
            if ($extendedInformation)
            {
                $adminRelationship = @{
                    "@" = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
                    AccessAssignments = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Headers $headers
                    Operations = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/operations" -Headers $headers
                    Requests = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests" -Headers $headers
                }
            }
            else {
                $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
            }
            
            return $adminRelationship
        }
    }
    catch {
        throw "Authorization failed or bad request.`nException: $($_.Exception.Message)"
    }
}
