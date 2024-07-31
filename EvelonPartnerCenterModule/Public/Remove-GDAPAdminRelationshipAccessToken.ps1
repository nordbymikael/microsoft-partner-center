function Remove-GDAPAdminRelationshipAccessToken {
    try {
        Write-Verbose -Message "Checking if Microsoft Authentication Library module is available or installed."

        if (((Get-Module -ListAvailable | Select-Object -Property "Name") | Where-Object -Property "Name" -eq "MSAL.PS") -ne $null)
        {
            Write-Verbose -Message "Importing the MSAL.PS module."
            Import-Module MSAL.PS -ErrorAction "Stop"
        }
        else {
            Write-Verbose -Message "The Microsoft Authentication Library module is not installed. Read the documentation to install the module."
            Write-Error -Message "The Microsoft Authentication Library module is not installed. Read the documentation to install the module."
            return
        }

        Clear-MsalTokenCache -ErrorAction "Stop"
        Write-Verbose -Message "Cleared all Microsoft Authentication Library generated tokens from cache."
    }
    catch {
        Write-Verbose -Message "Could not clear the access tokens from the Microsoft Authentication Library module cache."
        Write-Error -Message "Could not clear the access tokens from the Microsoft Authentication Library module cache."
        return
    }
}
