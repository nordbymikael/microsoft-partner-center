function Disconnect-CMPC {
    #REQUIRES -Version 4.0

    <#
    .SYNOPSIS
    This function stops your connection to the Partner Center tenant.

    .DESCRIPTION
    This function tests if an instance of the authTokenManager class exists, and will try to dispose it if it exists.  

    .INPUTS
    This function does not accept any parameters.

    .OUTPUTS
    This function outputs whether the disposal of the authTokenManager class was successful. 
    If the class that handles authentication was altered by the user (what you should not do), the function might fail and throw a terminating error.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#disconnect-cmpc

    .NOTES
    This function disposes the authTokenManager that was created by Connect-CMPC.
    If the variable authTokenManager (which should be a class) exists, then the function tries to dispose the class and set the class instance value to null.
    The function will simply inform the user if the user is already disconnected from the Partner Center tenant.
    If the class that handles authentication was altered by the user (what you should not do), the function might fail and throw a terminating error.

    .EXAMPLE
    Disconnect-CMPC
    This example shows how to disconnect from the Partner Center tenant.
    #>

    [CmdletBinding(
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#disconnect-cmpc",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param ()

    begin
    {
        
    }

    process
    {
        if ($null -ne $authTokenManager)
        {
            try {
                $global:authTokenManager.Dispose()
                $global:authTokenManager = $null
            }
            catch {
                throw "The authTokenManager class has been altered and this caused an unexpected error: $($_)"
            }
            
            Write-Host -Object "Successfully disconnected from CMPC." -ForegroundColor "Green"
        }
        else {
            Write-Host -Object "Already disconnected from CMPC." -ForegroundColor "Green"
        }
    }

    end
    {
        
    }
}
