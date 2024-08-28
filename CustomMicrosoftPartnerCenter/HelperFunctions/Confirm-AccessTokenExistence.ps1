function Confirm-AccessTokenExistence {
    [CmdletBinding()]

    param ()
    
    begin
    {
        
    }

    process
    {
        if ([System.String]::IsNullOrEmpty($authTokenManager.Token))
        {   
            Write-Verbose -Message "An access token in the authTokenManager does not exist."
            throw "Connect to the Partner Center tenant using Connect-CMPC before running this function."
        }
        
        Write-Verbose -Message "An access token in the authTokenManager exists."
    }
    
    end
    {
        
    }
}
