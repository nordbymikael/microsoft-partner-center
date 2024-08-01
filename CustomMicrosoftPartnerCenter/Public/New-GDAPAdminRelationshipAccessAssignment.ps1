function New-GDAPAdminRelationshipAccessAssignment {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [switch]$exportAsJSON,
        [Parameter(Mandatory = $false)] [switch]$exportAsCSV,
        [Parameter(Mandatory = $false)] [string]$csvDelimiter = ";",
        [Parameter(Mandatory = $false)] [string]$exportPath = "NotDefined"
    )

    Write-Verbose -Message "Defining the variable with error information."
    $errorInfo = @{
        Status = "Failed"
        RelationshipId = $adminRelationshipId
    }

    <#if ((Convert-JWTToken -accessToken $accessToken) -ne "Success")
    {
        Write-Verbose -Message "The access token has insufficient permissions."
        Write-Error -Message "The access token has insufficient permissions."
        return $errorInfo
    }#>
    
    if ($exportPath -eq "")
    {
        Write-Verbose -Message "The export path cannot be an empty string."
        Write-Error -Message "The export path cannot be an empty string."
        return $errorInfo
    }

    if ((Export-PreCheck -exportPath $exportPath -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV) -ne "Success")
    {
        Write-Verbose -Message "Something went wrong while checking the validity of the export parameters."
        Write-Error -Message "Something went wrong while checking the validity of the export parameters."
        return $errorInfo
    }

    Write-Verbose -Message "Defining the header variable and the body variables."

    $accessAssignmentHeaders = @{
        Authorization = "Bearer $($accessToken)"
    }

    $accessAssignmentBody = @{
        accessContainer = @{
            accessContainerId = "" # Seciruty group ID will be defined later
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @() # Roles will be defined later
        }
    }

    try {
        Write-Verbose -Message "Starting the creation of access assignments on admin relationship:`nId: ($($adminRelationshipId))."

        Write-Verbose -Message "Converting roles from JSON to PSObject."
        $roles = $GDAPAccess | ConvertFrom-Json -ErrorAction "Stop"

        Write-Verbose -Message "Creating a summary variable of the API responses."
        $accessAssignmentsInfo = @{}

        foreach ($role in $roles) {
            try {
                Write-Verbose -Message "Modifying body variable."
                $accessAssignmentBody.accessContainer.accessContainerId = $role.securityGroupId
                $accessAssignmentBody.accessDetails.unifiedRoles = @(
                    @{
                        roleDefinitionId = $role.roleDefinitionId
                    }
                )

                Write-Verbose -Message "Creating access assignments for $($role.roleDefinitionId) ($($role.roleDefinitionName))."
                $accessAssignmentResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Method "Post" -ContentType "application/json" -Headers $accessAssignmentHeaders -Body ($accessAssignmentBody | ConvertTo-Json -Depth 100) -ErrorAction "Stop"
                
                Write-Verbose -Message "Response for $($role.roleDefinitionName):`n$($accessAssignmentResponse | ConvertTo-Json)"
                $accessAssignmentsInfo[$role.roleDefinitionId] = $accessAssignmentResponse
            }
            catch {
                Write-Verbose -Message "Access assignment failed for $($role.roleDefinitionId) ($($role.roleDefinitionName))."
                $accessAssignmentsInfo[$role.roleDefinitionId] = $accessAssignmentResponse
            }
        }
    }
    catch {
        Write-Verbose -Message "Could not assign access to Delegated Admin Relationship ID ($($adminRelationshipId))."
        Write-Error -Message "Could not assign access to Delegated Admin Relationship ID ($($adminRelationshipId))."
        return $errorInfo
    }

    try {
        Export-Result -objectToExport $accessAssignmentsInfo -exportPath $exportPath -csvDelimiter $csvDelimiter -exportAsJSON $exportAsJSON -exportAsCSV $exportAsCSV -ErrorAction "Stop"
    }
    catch {
        Write-Verbose -Message "Something went wrong while exporting the result."
        Write-Error -Message "Something went wrong while exporting the result."
        return $accessAssignmentsInfo
    }

    return $accessAssignmentsInfo
}
