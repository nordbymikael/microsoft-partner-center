function Convert-JWTtoken {
    param(
        [Parameter(Mandatory=$true)][string]$accessToken
    )
    try {
            # Access and ID tokens will be accepted, and refresh tokens will not work
            Write-Verbose -Message "Validating token format."
            if (($accessToken -contains ".") -eq $true -or $accessToken.StartsWith("eyJ") -eq $false -or ($accessToken.ToCharArray() | Where-Object { $_ -eq "." }).Count -ne 2)
            {
                Write-Verbose -Message "Invalid token format."
                Write-Error -Message "Invalid token format."
                return
            }
        
            Write-Verbose -Message "Formatting the token header."
            $accessTokenHeader = $accessToken.Split(".")[0].Replace('-', '+').Replace('_', '/')

            # Fix padding as needed by adding "=" until string length modulus 4 reaches 0
            Write-Verbose -Message "Fixing the token header padding in Base64 format."
            while ($accessTokenHeader.Length % 4)
            {
                Write-Verbose -Message "Added `"=`" to the token header."
                $accessTokenHeader += "="
            }
            
            Write-Verbose -Message "Converting token header from Base64 encoded string to PSObject."
            try {
                $validatedHeader = [System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($accessTokenHeader)) | ConvertFrom-Json | Format-List | Out-Default
            }
            catch {
                Write-Verbose -Message "Something is wrong with the token header."
            }
        
            Write-Verbose -Message "Retrieving token payload in correct format."
            $accessTokenPayload = $token.Split(".")[1].Replace('-', '+').Replace('_', '/')

            # Fix padding as needed by adding "=" until string length modulus 4 reaches 0
            Write-Verbose -Message "Fixing the token payload padding in Base64 format."
            while ($accessTokenPayload.Length % 4)
            {
                Write-Verbose -Message "Added `"=`" to the token payload."
                $accessTokenPayload += "="
            }

            Write-Verbose -Message "Converting token payload to a Byte array."
            $accessTokenByteArray = [System.Convert]::FromBase64String($accessTokenPayload)

            Write-Verbose -Message "Converting access token payload from a Byte array to JSON."
            $accessTokenJSON = [System.Text.Encoding]::ASCII.GetString($accessTokenByteArray)

            Write-Verbose -Message "Converting token payload from JSON to PSObject."
            $parsedToken = $accessTokenJSON | ConvertFrom-Json

            if ($parsedToken.scp.Contains("DelegatedAdminRelationship.ReadWrite.All") -eq $false)
            {
                Write-Verbose -Message "The access token has insufficient API permissions. Give the access token the following API permission: `"https://graph.microsoft.com/DelegatedAdminRelationship.ReadWrite.All`"."
                Write-Error -Message "The access token has insufficient API permissions. Give the access token the following API permission: `"https://graph.microsoft.com/DelegatedAdminRelationship.ReadWrite.All`"."
                return
            }

            Write-Verbose -Message "A valid token was provided to check."
            return "Success"
    }
    catch {
        Write-Verbose -Message "Something went wrong while parsing the access token to check access."
        Write-Error -Message "Something went wrong while parsing the access token to check access."
        return
    }
}

# Script block to paste to check permissions
<#if ((Convert-JWTToken -accessToken $accessToken) -ne "Success")
{
    Write-Verbose -Message "The access token has insufficient permissions."
    Write-Error -Message "The access token has insufficient permissions."
    return $errorInfo
}#>