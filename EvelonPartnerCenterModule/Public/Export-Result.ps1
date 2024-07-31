function Export-Result {
    param (
        [Parameter(Mandatory=$true)][PSCustomObject]$objectToExport,
        [Parameter(Mandatory=$true)][string]$exportPath,
        [Parameter(Mandatory = $true)][string]$csvDelimiter,
        [Parameter(Mandatory=$true)][bool]$exportAsJSON,
        [Parameter(Mandatory=$true)][bool]$exportAsCSV
    )

    Write-Verbose -Message "Checking if result can be exported."

    try {
        if ($exportAsCSV -eq $true -and $exportAsJSON -eq $false)
        {
            Write-Verbose -Message "Exporting as CSV."
            $objectToExport | Export-Csv -Path "$($exportPath).csv" -Delimiter $csvDelimiter -NoTypeInformation -ErrorAction "Stop"
            Write-Verbose -Message "Successfully exported as CSV."
            return
        }
        elseif ($exportAsCSV -eq $true -and $exportAsJSON -eq $true)
        {
            Write-Verbose -Message "Exporting as CSV."
            $objectToExport | Export-Csv -Path "$($exportPath).csv" -Delimiter $csvDelimiter -NoTypeInformation -ErrorAction "Stop"
            Write-Verbose -Message "Successfully exported as CSV."

            Write-Verbose -Message "Exporting as JSON."
            ($objectToExport | ConvertTo-Json -Depth 100 -ErrorAction "Stop") | Set-Content -Path "$($exportPath).json" -ErrorAction "Stop"
            Write-Verbose -Message "Successfully exported as JSON."
            return
        }
        elseif ($exportAsJSON -eq $true)
        {
            Write-Verbose -Message "Exporting as JSON."
            ($objectToExport | ConvertTo-Json -Depth 100 -ErrorAction "Stop") | Set-Content -Path "$($exportPath).json" -ErrorAction "Stop"
            Write-Verbose -Message "Successfully exported as JSON."
            return
        }
        else
        {
            Write-Verbose -Message "The user input did not specify to export the result."
            return
        }
    }
    catch {
        if ($exportAsCSV -eq $true)
        {
            Write-Verbose -Message "Failed to export admin relationship as CSV. Returning admin relationship information."
            Write-Error -Message "Failed to export admin relationship as CSV. Returning admin relationship information."
            return "Failed"
        }
        if ($exportAsJSON -eq $true)
        {
            Write-Verbose -Message "Failed to export admin relationship as JSON. Returning admin relationship information."
            Write-Error -Message "Failed to export admin relationship as JSON. Returning admin relationship information."
            return "Failed"
        }
    }
}
