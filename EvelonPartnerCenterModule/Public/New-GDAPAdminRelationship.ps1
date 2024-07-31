function New-GDAPAdminRelationship {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $false)] [string]$displayName = "EvelonCSPAdminRelationship" + (Get-Random).ToString(),
        [Parameter(Mandatory = $false)] [string]$duration = "P730D",
        [Parameter(Mandatory = $false)] [string]$autoExtendDuration = "P180D",
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
    
    try {
        Write-Verbose -Message "Converting roles from JSON to PSObject."
        $roles = $GDAPAccess | ConvertFrom-Json -ErrorAction "Stop"
        $unifiedRoles = @()
        foreach ($role in $roles) {
            $unifiedRoles += @{
                roleDefinitionId = $role.roleDefinitionId
            }
        }
    }
    catch {
        Write-Verbose -Message "Failed to import roles from JSON."
        Write-Error -Message "Failed to import roles from JSON."
        return
    }

    Write-Verbose -Message "Defining the header variable and the body variables."
    
    $adminRelationshipHeaders = @{
        Authorization = "Bearer $($accessToken)"
    }

    $adminRelationshipMainBody = @{
        displayName = $displayName
        duration = $duration
        accessDetails = @{
            unifiedRoles = $unifiedRoles
        }
        autoExtendDuration = $autoExtendDuration
    }

    $adminRelationshipLockForApprovalBody = @{
        action = "lockForApproval"
    }
    
    try {
        Write-Verbose -Message "Generating an admin relationship."
        $adminRelationshipResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships" -Method "Post" -ContentType "application/json" -Headers $adminRelationshipHeaders -Body ($adminRelationshipMainBody | ConvertTo-Json -Depth 100) -ErrorAction "Stop"
    
        Write-Verbose -Message "Locking the admin relationship for approval."
        $adminRelationshipLockForApprovalResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipResponse.id)/requests" -Method "Post" -ContentType "application/json" -Headers $adminRelationshipHeaders -Body ($adminRelationshipLockForApprovalBody | ConvertTo-Json -Depth 100) -ErrorAction "Stop"
        
        $adminRelationshipInfo = [PSCustomObject]@{
            displayName = $displayName
            id = $adminRelationshipResponse.id
            url = "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/" + $adminRelationshipResponse.id
        }
        
        Write-Verbose -Message "Admin relationship information:`n$($adminRelationshipResponse | ConvertTo-Json -Depth 100)"
        Write-Verbose -Message "Admin relationship lockForApproval response:`n$($adminRelationshipResponse | ConvertTo-Json -Depth 100)"
        Write-Verbose -Message "Admin relationship generated successfully."
    }
    catch {
        Write-Verbose -Message "Failed to create admin relationship. The access token might be expired, or the body parameters might be incorrect."
        Write-Error -Message "Failed to create admin relationship. The access token might be expired, or the body parameters might be incorrect."
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
