function Export-PreCheck {
    param (
        [Parameter(Mandatory=$true)][string]$exportPath,
        [Parameter(Mandatory=$true)][bool]$exportAsJSON,
        [Parameter(Mandatory=$true)][bool]$exportAsCSV
    )
    
    if ($exportAsCSV -eq $true -or $exportAsJSON -eq $true)
    {
        Write-Verbose -Message "Defining the export path directory and file name without file extention."
        $exportPathDirectory = (Split-Path -Path $exportPath -Parent).ToLower()
        $exportPathFileName = (Split-Path -Path $exportPath -Leaf).ToLower()
        
        if ($exportPath -eq "NotDefined")
        {
            Write-Verbose -Message "If `$exportAsJSON or `$exportAsCSV is `$true, then `$exportPath has to be specified."
            Write-Error -Message "If `$exportAsJSON or `$exportAsCSV is `$true, then `$exportPath has to be specified."
            return "Failed"
        }
        if (($exportPathFileName.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count -ne 0)
        {
            Write-Verbose -Message "`"$($exportPath)`" is an invalid path for this function. Please read the documentation."
            Write-Error -Message "`"$($exportPath)`" is an invalid path for this function. Please read the documentation."
            return "Failed"
        }
        if ((Test-Path $exportPathDirectory) -eq $false)
        {
            Write-Verbose -Message "The folder of `$exportPath is not valid. Please read the documentation."
            Write-Error -Message "The folder of `$exportPath is not valid. Please read the documentation."
            return "Failed"
        }
    }

    return "Success"
}
