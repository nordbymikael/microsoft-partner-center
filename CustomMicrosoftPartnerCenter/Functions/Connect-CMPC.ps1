function Connect-CMPC {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function handles authentication.

    .DESCRIPTION
    This function handles authentication by creating a Powershell class and authenticating to an App Registration in Entra ID.
    The purpose of the function is to fully manage authentication by always providing a valid access token with the "DelegatedAdminRelationship.ReadWrite.All" permission.
    This function is supposed to only be called once, at the start of the script where the module is used.
    All functions in the module are dependent on this particular function to function properly.

    It is important to not interfer with the class that is created by the function and the parameters associated with it.
    Any changes will most likely create unextected errors.

    .PARAMETER tenantId
    The Tenant ID of your Microsoft Partner Center tenant.
    This parameter has to be a globally unique identifier (GUID) provided as a string.

    .PARAMETER clientId
    The Application ID or Client ID of your App Registration in Entra ID that has the "DelegatedAdminRelationship.ReadWrite.All" API permission.
    This parameter has to be a globally unique identifier (GUID) provided as a string.

    .PARAMETER clientSecret
    The Client Secretof your App Registration in Entra ID that has the "DelegatedAdminRelationship.ReadWrite.All" API permission.
    This parameter is a secret string that you only see once, when creating the secret in Entra ID.

    .PARAMETER usePredefinedVariables
    The usePredefinedVariables parameter uses variables from the <module-root-directory>\Configuration\Configuration.ps1 file.
    To use this parameter, all three variables CMPC_TenantId, CMPC_ClientId and CMPC_ClientSecret have to be defined.
    It is recommended to not write the values directly in the configuration file, but rather use environment variables.

    .INPUTS
    This function accepts two different input patterns.
    You can manually provide a Tenant ID, an Application ID (or a Client ID) and a client secret, or you can define them in a configuration file and use the usePredefinedVariables parameter to use the values from the configuration file.

    .OUTPUTS
    This function produces an output about the connection state.
    This function throws an error if the authentication state is unsuccessful.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#connect-cmpc

    .NOTES
    This function first defines some variables.
    The token and refresh token variables are empty strings.
    The expiry indicates the expiry of the current token. The type is datetime and the value is the token expiration date and time in the UTC time zone.
    The refresh expiry indicates the expiry of the current refresh token. The type is datetime and the value is the token expiration date and time in the UTC time zone.
    The Tenand ID, Client ID and client secret are strings and are defined by the user when the function is called, either directly or in the configuration file.
    The permission is a static string with the DelegatedAdminRelationship.ReadWrite.All API permission that is required for the module to function.

    When the function is first called, the Powershell class authTokenManager is created and the GetNewToken function within the class is called to create the first access token.
    If the Connect-CMPC function is called a second time and the class was not disposed using the Disconnect-CMPC function, the output is "Already connected to CMPC".
    
    After a successful connection, the logic comes in place. This logic uses the GetValidToken function within the class in the backend of every function and is not maintained by the end user (the process is automatic).
    The class is always called in the backend by the other functions to validate the access token validitiy, before calling the API.
    If the access token is noe expired, then the class returns the existing access token as a plain string that is stored inside the class in the token variable.
    If the refresh token exists and is not expired, a new access token is retrieved using the refresh token.
    If none of the conditions are met, a whole new access token is created.

    .EXAMPLE
    Connect-CMPC -tenantId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -clientId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -clientSecret "your-secret"
    This example shows how to connect to CMPC using a Tenant ID, an Application ID (Client ID) and a client secret.

    .EXAMPLE
    Connect-CMPC -usePredefinedVariables
    This example shows how to connect to CMPC while still using a Tenant ID, an Application ID (or a Client ID) and a client secret, but they are predefined in the variables.ps1 file.
    Read the documentation for the usePredefinedVariables parameter for more help.
    #>

    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "Direct",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#connect-cmpc",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$tenantId,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$clientId,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [System.String]$clientSecret,

        [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationFile")]
        [System.Management.Automation.SwitchParameter]$usePredefinedVariables
    )

    begin
    {
        
    }

    process
    {
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
                        throw "Failed to obtain token: $($_)"
                    }
                    
                    $this.ValidateTokenPermissions($response.access_token)
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

                [void]ValidateTokenPermissions([string]$newToken) {
                    $payload = ($newToken -split '\.')[1]

                    # Sleep a little amount of time because the dotnet conversion method fails somethimes if the payload does not get into memory fast enough
                    try {
                        Start-Sleep -Milliseconds 200
                        $payloadJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
                    }
                    catch {
                        throw "Failed to parse the token to validate the token permissions, please try again after Disconnect-CMPC: $($_)"
                    }
                    
                    $payloadHashtable = $payloadJson | ConvertFrom-Json

                    if ($payloadHashtable.roles -notcontains "DelegatedAdminRelationship.ReadWrite.All")
                    {
                        throw "The token has insufficient permissions: $($_)"
                    }
                }
            
                [string]GetValidToken() {
                    if ([System.DateTime]::get_Now().ToUniversalTime() -lt $this.Expiry.addSeconds(-60)) {
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

            Write-Host -Object "Successfully connected to CMPC." -ForegroundColor "Green"
        }
        else {
            Write-Host -Object "Already connected to CMPC." -ForegroundColor "Green"
        }
    }

    end
    {

    }
}
