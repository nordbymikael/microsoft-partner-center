function Get-AllGraphAPIResponses {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [securestring]$accessToken,
        [Parameter(Mandatory = $true)] [string]$uri
    )
    
    $responseCollection = @()
    $headers = @{
        Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken)"
    }

    do {
        $response = Invoke-RestMethod -Method "Get" -Uri $uri -Headers $headers
        $responseCollection += $response.value
        $uri = $response."@odata.nextLink"
    } while ($uri)
    
    return $responseCollection
}
