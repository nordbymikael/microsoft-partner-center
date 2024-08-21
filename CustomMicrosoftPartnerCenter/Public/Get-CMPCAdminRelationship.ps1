function Get-CMPCAdminRelationship {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $false)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [switch]$extendedInformation
    )

    if (!$adminRelationshipId)
    {
        $uri = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"

        if ($extendedInformation)
        {
            $adminRelationshipCollection = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri $uri

            foreach ($adminRelationshipObject in $adminRelationshipCollection) {
                $adminRelationship = @{
                    "@" = $adminRelationshipObject
                    accessAssignments = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/accessAssignments"
                    operations = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/operations"
                    requests = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/requests"
                }
                $allAdminRelationships += $adminRelationship
            }
        }
        else {
            $allAdminRelationships = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri $uri
        }

        return $allAdminRelationships
    }
    else {
        $headers = @{
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
        }
        $adminRelationshipObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
        $adminRelationshipObject.PSObject.Properties.Remove("@odata.context")

        if ($extendedInformation)
        {
            $adminRelationship = @{
                "@" = $adminRelationshipObject
                AccessAssignments = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments"
                Operations = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/operations"
                Requests = Get-AllGraphAPIResponses -accessToken $accessToken.DelegatedAdminRelationship -uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests"
            }
        }
        else {
            $adminRelationship = $adminRelationshipObject
        }
        
        return $adminRelationship
    }
}
