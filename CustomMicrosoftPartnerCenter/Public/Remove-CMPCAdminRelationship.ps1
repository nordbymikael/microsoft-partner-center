function Remove-CMPCAdminRelationship {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId
    )
    
    try {
        $headers = @{
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
        }
        $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
        $headers["If-Match"] = $adminRelationship."@odata.etag"

        switch ($adminRelationship.status)
        {
            "created" {
                Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers > $null
            }
            "active" {
                $headers["Authorization"] = "Bearer $(Unprotect-SecureString -secureString $accessToken.PartnerCustomerDelegatedAdministration)"
                $body = @{
                    status = "terminationRequested"
                }
                Invoke-RestMethod -Method "Post" -Uri "https://traf-pcsvcadmin-prod.trafficmanager.net/CustomerServiceAdminApi/Web/v1/granularAdminRelationships/$($adminRelationship.id)/UpdateStatus" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
            }
            "approvalPending" {
                return "The admin relationship with id $($adminRelationshipId) cannot be ended because it has the `"approvalPending`" status. Accept the admin relationship before removing it."
            }
            default {
                return "The admin relationship with id $($adminRelationshipId) has already ended."
            }
            
        }
    
        return "Ended the admin relationship with the id $($adminRelationshipId)."
    }
    catch {
        throw "Authorization failed or bad request.`nException: $($_.Exception.Message)"
    }
}
