function Confirm-AdminRelationshipExistence {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.String]$AdminRelationshipId
    )
    
    begin
    {
        Confirm-AccessTokenExistence
        
        $Headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    }

    process
    {
        try {
            Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)" -Headers $Headers > $null
        }
        catch {
            throw "The specified admin relationship does not exist."
        }
    }
    
    end
    {
        
    }
}
