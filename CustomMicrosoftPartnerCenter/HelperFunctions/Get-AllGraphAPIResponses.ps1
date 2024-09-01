function Get-AllGraphAPIResponses {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.String]$Uri
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
        while ($Uri)
        {
            $response = Invoke-RestMethod -Method "Get" -Uri $Uri -Headers $headers
            $responseCollection += $response.value
            $Uri = $response."@odata.nextLink"
        }
    }
    
    end
    {
        return $responseCollection
    }
}
