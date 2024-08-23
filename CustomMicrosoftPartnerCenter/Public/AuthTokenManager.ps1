class AuthTokenManager : IDisposable {
    [string]$Token
    [string]$RefreshToken
    [datetime]$Expiry
    [datetime]$RefreshExpiry
    [string]$TenantId
    [string]$ClientId
    [string]$ClientSecret

    AuthTokenManager([string]$tenantId, [string]$clientId, [string]$clientSecret) {
        $this.TenantId = $tenantId
        $this.ClientId = $clientId
        $this.ClientSecret = $clientSecret
        $this.Token = ""
        $this.RefreshToken = ""
        $this.Expiry = [datetime]::MinValue
        $this.RefreshExpiry = [datetime]::MinValue
        $this.GetNewToken()
    }

    [void]RequestToken([hashtable]$body) {
        try {
            $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($this.TenantId)/oauth2/v2.0/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
            $this.Token = $response.access_token
            $this.Expiry = (Get-Date).ToUniversalTime().AddSeconds($response.expires_in)
            
            if ($response.keys -contains "refresh_token") {
                $this.RefreshToken = $response.refresh_token
                $this.RefreshExpiry = (Get-Date).ToUniversalTime().AddDays(1)
            }
        } catch {
            throw "Failed to obtain token: $_"
        }
    }

    [void]GetNewToken() {
        $body = @{
            client_id     = $this.ClientId
            client_secret = $this.ClientSecret
            scope         = "https://graph.microsoft.com/.default"
            grant_type    = "client_credentials"
        }
        $this.RequestToken($body)
    }

    [void]RefreshToken() {
        $body = @{
            client_id     = $this.ClientId
            client_secret = $this.ClientSecret
            scope         = "https://graph.microsoft.com/.default"
            grant_type    = "refresh_token"
            refresh_token = $this.RefreshToken
        }
        $this.RequestToken($body)
    }

    [string]GetValidToken() {
        if ((Get-Date).ToUniversalTime() -lt $this.Expiry) {
            return $this.Token
        } elseif ((Get-Date).ToUniversalTime() -lt $this.RefreshExpiry -and $this.RefreshToken) {
            $this.RefreshToken()
            return $this.Token
        } else {
            $this.GetNewToken()
            return $this.Token
        }
    }

    [void]Dispose() {
        $this.Token = $null
        $this.RefreshToken = $null
        $this.TenantId = $null
        $this.ClientId = $null
        $this.ClientSecret = $null
        $this.Expiry = [datetime]::MinValue
        $this.RefreshExpiry = [datetime]::MinValue
        
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

<#
# Example usage
$authTokenManager = [AuthTokenManager]::new("your_tenant_id", "your_client_id", "your_client_secret")
$validToken = $authTokenManager.GetValidToken()

# Clean up resources when done
$authTokenManager.Dispose()
$authTokenManager = $null
#>
