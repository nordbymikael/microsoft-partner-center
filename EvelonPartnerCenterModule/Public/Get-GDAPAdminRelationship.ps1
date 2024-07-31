function Get-GDAPAdminRelationship {
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
        if ($adminRelationshipId -ne "*")
        {
            Write-Verbose -Message "Retrieving general information about the admin relationship."
            $adminRelationshipGeneralInfo = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Method "Get" -ContentType "application/json" -Headers $headers -ErrorAction "Stop"
            Write-Verbose -Message "Response:`n$($adminRelationshipGeneralInfo | ConvertTo-Json -Depth 100)"

            Write-Verbose -Message "Retrieving admin relationship access assignments."
            $adminRelationshipAccessAssignmentsInfo = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Method "Get" -ContentType "application/json" -Headers $headers -ErrorAction "Stop"
            Write-Verbose -Message "Response:`n$($adminRelationshipAccessAssignmentsInfo | ConvertTo-Json -Depth 100)"

            Write-Verbose -Message "Retrieving admin relationship requests."
            $adminRelationshipRequestsInfo = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests" -Method "Get" -ContentType "application/json" -Headers $headers -ErrorAction "Stop"
            Write-Verbose -Message "Response:`n$($adminRelationshipRequestsInfo | ConvertTo-Json -Depth 100)"
            
            Write-Verbose -Message "Successfully retrieved all admin relationship information."

            Write-Verbose -Message "Generating variable for summary."
            $adminRelationshipInfo = [PSCustomObject]@{
                General = $adminRelationshipGeneralInfo
                AccessAssignments = $adminRelationshipAccessAssignmentsInfo
                Requests = $adminRelationshipRequestsInfo
            }
        }
        elseif ($adminRelationshipId -eq "*")
        {
            Write-Verbose -Message "Retrieving general information about all admin relationships."
            $adminRelationships = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/" -Method "Get" -ContentType "application/json" -Headers $headers -ErrorAction "Stop"
            Write-Verbose -Message "Response:`n$($adminRelationships | ConvertTo-Json -Depth 100)"

            Write-Verbose -Message "Generating variable for summary."
            $adminRelationshipInfo = [PSCustomObject]@{
                General = $adminRelationships
            }
        }
    }
    catch {
        Write-Verbose -Message "Something went wrong while trying to get information about admin relationship. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        Write-Error -Message "Something went wrong while trying to get information about admin relationship. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        return
    }

    try {
        Export-Result -objectToExport $adminRelationshipInfo -exportPath $exportPath -csvDelimiter $csvDelimiter -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV -ErrorAction "Stop"
    }
    catch {
        Write-Verbose -Message "Something went wrong while exporting the result."
        Write-Error -Message "Something went wrong while exporting the result."
        return $adminRelationshipInfo
    }

    return $adminRelationshipInfo
}
