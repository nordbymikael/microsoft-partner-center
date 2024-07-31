function Get-GDAPAdminRelationshipAccessToken {
    param (
        [Parameter(Mandatory = $false)] [string]$clientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e",
        [Parameter(Mandatory = $false)] [string]$tenantId = "72465188-6db8-4510-ba33-40392d5db724",
        [Parameter(Mandatory = $false)] [string]$scope = "https://graph.microsoft.com/DelegatedAdminRelationship.ReadWrite.All"
    )

    try {
        Write-Verbose -Message "Checking if Microsoft Authentication Library module is available or installed."
        
        if (((Get-Module -ListAvailable | Select-Object -Property "Name") | Where-Object -Property "Name" -eq "MSAL.PS") -ne $null)
        {
            Write-Verbose -Message "Importing the MSAL.PS module."
            Import-Module MSAL.PS -ErrorAction "Stop"
            
            Write-Verbose -Message "Performing authentication and obtaining an access token."
            $accessToken = Get-MsalToken -ClientId $clientId -TenantId $tenantId -Scope $scope

            Write-Verbose -Message "Successfully generated access token."
            return $accessToken.AccessToken
        }
        else {
            Write-Verbose -Message "The Microsoft Authentication Library module is not installed. Read the documentation to install the module."
            Write-Error -Message "The Microsoft Authentication Library module is not installed. Read the documentation to install the module."
            return
        }
    }
    catch {
        Write-Verbose -Message "Something went wrong while obtaining the access token."
        Write-Error -Message "Something went wrong while obtaining the access token."
        return
    }
}
