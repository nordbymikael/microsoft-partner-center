function Get-GDAPMissingAdminRelationshipAccessAssignment {
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

    try {
        Write-Verbose -Message "Retrieving information about the admin relationship access assignment."
        $adminRelationshipAccessAssignmentResponse = Get-GDAPAdminRelationshipAccessAssignment -accessToken $accessToken -adminRelationshipId $adminRelationshipId
        
        Write-Verbose -Message "Converting roles from JSON to PSObject."
        $roles = $GDAPAccess | ConvertFrom-Json -ErrorAction "Stop"

        Write-Verbose -Message "Generating a variable for missing access assignment."
        $adminRelationshipMissingAccessAssignmentInfo = @{}

        Write-Verbose -Message "Starting to loop through the existing access assignments and trying to find missing."
        foreach ($role in $roles)
        {
            # Write-Verbose -Message "Checking $($role.securityGroupId) ($($role.roleDefinitionName))."
            if ($role.securityGroupId -notin $adminRelationshipAccessAssignmentResponse.AllResponses.Value.accessContainer.accessContainerId)
            {
                Write-Verbose -Message "An access assignment for $($role.securityGroupId) does not exist."
                $adminRelationshipMissingAccessAssignmentInfo[$role.securityGroupId] = "Missing"
            }
        }
    }
    catch {
        Write-Verbose -Message "Something went wrong while trying to get information about admin relationship access assignment. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        Write-Error -Message "Something went wrong while trying to get information about admin relationship access assignment. A common cause of this error is that the relationship does not exist, or the access token might be expired."
        return
    }

    try {
        Export-Result -objectToExport $adminRelationshipMissingAccessAssignmentInfo -exportPath $exportPath -csvDelimiter $csvDelimiter -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV -ErrorAction "Stop"
    }
    catch {
        Write-Verbose -Message "Something went wrong while exporting the result."
        Write-Error -Message "Something went wrong while exporting the result."
        return $adminRelationshipMissingAccessAssignmentInfo
    }

    return $adminRelationshipMissingAccessAssignmentInfo
}
