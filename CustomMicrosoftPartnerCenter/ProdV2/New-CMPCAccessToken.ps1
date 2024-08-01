function New-CMPCAccessToken {
    param (
        [Parameter(Mandatory = $false)] [string]$tenantId = $CMPC_TenantId,
        [Parameter(Mandatory = $false)] [string]$clientId = $CMPC_ClientId,
        [Parameter(Mandatory = $false)] [string]$clientSecret = $CMPC_ClientSecret
    )

    if (![bool]$tenantId -or ![bool]$client_id -or ![bool]$clientSecret)
    {
        throw "At least one of the mandaroty parameters for authentication is not provided (Tenand ID, Client ID or Client secret)."
    }
    try {
        $body = @{
            client_id     = $clientId
            scope         = "https://graph.microsoft.com/.default"
            client_secret = $clientSecret
            grant_type    = "client_credentials"
        }
        
        $response = Invoke-RestMethod -Method "Post" -Uri "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
        
        return $response.access_token
    }
    catch {
        throw "Authentication failed.`nException: $($_.Exception.Message)"
    }
}
