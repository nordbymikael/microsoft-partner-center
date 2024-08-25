function Connect-CMPC {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$tenantId,
        [Parameter(Mandatory = $true)] [string]$clientId,
        [Parameter(Mandatory = $true)] [string]$clientSecret
    )

    if ($null -eq $authTokenManager)
    {
        class AuthTokenManager : IDisposable {
            [string]$Token
            [string]$RefreshToken
            [datetime]$Expiry
            [datetime]$RefreshExpiry
            [string]$TenantId
            [string]$ClientId
            [string]$ClientSecret
            [string]$Permission
        
            AuthTokenManager([string]$tenantId, [string]$clientId, [string]$clientSecret) {
                $this.TenantId = $tenantId
                $this.ClientId = $clientId
                $this.ClientSecret = $clientSecret
                $this.Token = ""
                $this.RefreshToken = ""
                $this.Expiry = [datetime]::MinValue
                $this.RefreshExpiry = [datetime]::MinValue.AddSeconds(10)
                $this.Permission = "DelegatedAdminRelationship.ReadWrite.All"
                $this.GetNewToken()
            }
        
            [void]RequestToken([hashtable]$body) {
                try {
                    $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($this.TenantId)/oauth2/v2.0/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
                }
                catch {
                    throw "Failed to obtain token: $_"
                }

                #$this.ValidateTokenPermissions($response.access_token)
                $this.Token = $response.access_token
                $this.Expiry = [System.DateTime]::get_Now().ToUniversalTime().AddSeconds($response.expires_in)
                
                if ($response.keys -contains "refresh_token") {
                    $this.RefreshToken = $response.refresh_token
                    $this.RefreshExpiry = [System.DateTime]::get_Now().ToUniversalTime().AddDays(1)
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

            [void]ValidateTokenPermissions([string]$token) {
                # Parse token and throw terminating error if it does not have correct permission in comparison to $this.Permission
                Continue
            }
        
            [string]GetValidToken() {
                if ([System.DateTime]::get_Now().ToUniversalTime() -lt $this.Expiry.addSeconds(-10)) {
                    return $this.Token
                } elseif ([System.DateTime]::get_Now().ToUniversalTime() -lt $this.RefreshExpiry.addSeconds(-10) -and $this.RefreshToken) {
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
                $this.Permission = $null
                
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()
            }
        }

        $global:authTokenManager = [AuthTokenManager]::new($tenantId, $clientId, $clientSecret)

        Write-Output -InputObject "Successfully connected to CMPC."
    }
    else {
        Write-Output -InputObject "Already connected to CMPC."
    }
}
