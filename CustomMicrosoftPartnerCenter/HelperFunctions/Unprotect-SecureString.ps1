function Unprotect-SecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [securestring]$secureString
    )
    
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
}
