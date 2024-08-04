function New-CMPCAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] [string]$tenantId,
        [Parameter(Mandatory = $false)] [string]$clientId,
        [Parameter(Mandatory = $false)] [string]$clientSecret,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedVariables
    )

    if ($usePredefinedVariables)
    {
        if ($CMPC_TenantId)
        {
            $tenantId = $CMPC_TenantId
        }
        if ($CMPC_ClientId)
        {
            $clientId = $CMPC_ClientId
        }
        if ($CMPC_ClientSecret)
        {
            $clientSecret = $CMPC_ClientSecret
        }
    }

    if (!$tenantId -or !$clientId -or !$clientSecret)
    {
        throw "At least one of the mandaroty parameters for authentication is not provided (tenantId, clientId or clientSecret)."
    }

    try {
        $tokens = @{}
        $tokenUri = "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token"
        $scopePartnerCustomerDelegatedAdministration = "https://api.partnercustomeradministration.microsoft.com/.default"
        $scopeDelegatedAdminRelationship = "https://graph.microsoft.com/.default"
        $body = @{
            client_id     = $clientId
            scope         = $scopeDelegatedAdminRelationship
            client_secret = $clientSecret
            grant_type    = "client_credentials"
        }
        $tokenDelegatedAdminRelationship = Invoke-RestMethod -Method "Post" -Uri "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
        $tokens["DelegatedAdminRelationship"] = (ConvertTo-SecureString -String $tokenDelegatedAdminRelationship.access_token -AsPlainText -Force)

        Start-Process -FilePath "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/authorize?client_id=$($clientId)&response_type=code&redirect_uri=http://localhost:8080&response_mode=query&scope=$($scopePartnerCustomerDelegatedAdministration)&state=12345"
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:8080/")
        $listener.Start()
        $context = $listener.GetContext()
        $authorizationCode = $context.Request.QueryString["code"]
        $listener.Stop()
        $body = @{
            client_id     = $clientId
            redirect_uri  = "http://localhost:8080/"
            client_secret = $clientSecret
            code          = $authorizationCode
            grant_type    = "authorization_code"
        }

        $tokenPartnerCustomerDelegatedAdministration = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$($tenantId)/oauth2/token" -ContentType "application/x-www-form-urlencoded" -Body $body
        $tokens["PartnerCustomerDelegatedAdministration"] = (ConvertTo-SecureString -String $tokenPartnerCustomerDelegatedAdministration.access_token -AsPlainText -Force)

        return $tokens
    }
    catch {
        throw "Authentication failed.`nException: $($_.Exception.Message)"
    }
}
