function Get-GDAPAdminRelationshipAccessAssignment {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [switch]$exportAsJSON,
        [Parameter(Mandatory = $false)] [switch]$exportAsCSV,
        [Parameter(Mandatory = $false)] [string]$csvDelimiter = ";",
        [Parameter(Mandatory = $false)] [string]$exportPath = "NotDefined"
    )

    <#if ((Convert-JWTToken -accessToken $accessToken) -ne "Success")
    {
        Write-Verbose -Message "The access token has insufficient permissions."
        Write-Error -Message "The access token has insufficient permissions."
        return
    }#>

    if ($exportPath -eq "")
    {
        Write-Verbose -Message "The export path cannot be an empty string."
        Write-Error -Message "The export path cannot be an empty string."
        return
    }

    if ((Export-PreCheck -exportPath $exportPath -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV) -ne "Success")
    {
        Write-Verbose -Message "Something went wrong while checking the validity of the export parameters."
        Write-Error -Message "Something went wrong while checking the validity of the export parameters."
        return
    }

    $headers = @{
        Authorization = "Bearer $($accessToken)"
    }

    try {
        Write-Verbose -Message "Retrieving all information about the admin relationship access assignment."
        $adminRelationshipAccessAssignmentResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Method "Get" -ContentType "application/json" -Headers $headers -ErrorAction "Stop"
        Write-Verbose -Message "Response:`n$($adminRelationshipAccessAssignmentResponse | ConvertTo-Json -Depth 100)"

        Write-Verbose -Message "Generating variable for summary."
        $adminRelationshipAccessAssignmentInfo = [PSCustomObject]@{
            AllResponses = $adminRelationshipAccessAssignmentResponse
        }
    }
    catch {
        Write-Verbose -Message "Something went wrong while trying to get information about admin relationship access assignment. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        Write-Error -Message "Something went wrong while trying to get information about admin relationship access assignment. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        return
    }

    try {
        Export-Result -objectToExport $adminRelationshipAccessAssignmentInfo -exportPath $exportPath -csvDelimiter $csvDelimiter -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV -ErrorAction "Stop"
    }
    catch {
        Write-Verbose -Message "Something went wrong while exporting the result."
        Write-Error -Message "Something went wrong while exporting the result."
        return $adminRelationshipAccessAssignmentInfo
    }

    return $adminRelationshipAccessAssignmentInfo
}
