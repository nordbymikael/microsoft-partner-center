function Get-AllGraphAPIResponses {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)] [string]$uri
    )
    
    begin
    {
        Confirm-AccessTokenExistence
        
        $responseCollection = @()
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    }

    process
    {
        do {
            $response = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
            $responseCollection += $response.value
            $uri = $response."@odata.nextLink"
        } while ($uri)
    }
    
    end
    {
        return $responseCollection
    }
}
