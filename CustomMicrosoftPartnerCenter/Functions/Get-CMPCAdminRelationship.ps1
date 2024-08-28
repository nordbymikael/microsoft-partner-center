function Get-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function retrieves information about one or more admin relationships.

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
    The usePredefinedVariables parameter uses variables from the <module-root-directory>\Configuration\Variables.ps1 file.
    To use this parameter, all three variables CMPC_TenantId, CMPC_ClientId and CMPC_ClientSecret have to be defined.
    It is recommended to not write the values directly in the configuration file, but rather use environment variables.

    .INPUTS
    This function accepts two different input patterns.
    You can manually provide a Tenant ID, an Application ID (or a Client ID) and a client secret, or you can define them in a configuration file and use the usePredefinedVariables parameter to use the values from the configuration file.

    .OUTPUTS
    This function produces an output about the connection state.
    This function throws an error if the authentication state is unsuccessful.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationship

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

    .EXAMPLE
    Connect-CMPC -tenantId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -clientId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -clientSecret "your-secret"
    This example shows how to connect to CMPC using a Tenant ID, an Application ID (Client ID) and a client secret.

    .EXAMPLE
    Connect-CMPC -usePredefinedVariables
    This example shows how to connect to CMPC while still using a Tenant ID, an Application ID (or a Client ID) and a client secret, but they are predefined in the variables.ps1 file.
    Read the documentation for the usePredefinedVariables parameter for more help.
    #>

    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$adminRelationshipId,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [System.Management.Automation.SwitchParameter]$extendedInformation
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if (!$adminRelationshipId)
        {
            $adminRelationshipCollection = Get-AllGraphAPIResponses -Uri $uri
    
            if ($extendedInformation)
            {
                $allAdminRelationships = @()
    
                foreach ($adminRelationshipObject in $adminRelationshipCollection) {
                    $adminRelationship = @{
                        "@" = $adminRelationshipObject
                        accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/accessAssignments"
                        operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/operations"
                        requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/requests"
                    }
                    $allAdminRelationships += $adminRelationship
                }
    
                return $allAdminRelationships
            }
            
            return $adminRelationshipCollection
        }
        else {
            $headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            $adminRelationshipObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
            $adminRelationshipObject.PSObject.Properties.Remove("@odata.context")
    
            if ($extendedInformation)
            {
                $adminRelationship = @{
                    "@" = $adminRelationshipObject
                    AccessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments"
                    Operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/operations"
                    Requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests"
                }
    
                return $adminRelationship
            }
            
            return $adminRelationshipObject
        }
    }

    end
    {

    }
}
