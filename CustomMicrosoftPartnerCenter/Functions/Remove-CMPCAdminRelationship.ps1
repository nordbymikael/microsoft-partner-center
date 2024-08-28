function Remove-CMPCAdminRelationship {
    [CmdletBinding(
        ConfirmImpact = "High",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$adminRelationshipId
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
    $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers

    switch ($adminRelationship.status)
    {
        "active" {
            $body = @{
                action = "terminate"
            }
            
            Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
        }
        "created" {
            $headers."If-Match" = $adminRelationship."@odata.etag"

            Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers > $null
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
