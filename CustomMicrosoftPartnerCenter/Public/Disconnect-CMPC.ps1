function Disconnect-CMPC {
    [CmdletBinding()]
    param ()

    if ($null -ne $authTokenManager)
    {
        $global:authTokenManager.Dispose()
        $global:authTokenManager = $null

        Write-Output -InputObject "Successfully disconnected from CMPC."
    }
    else {
        Write-Output -InputObject "Already disconnected from CMPC."
    }
}
