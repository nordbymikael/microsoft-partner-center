function Get-GDAPMissingAdminRelationshipAccessAssignment {
    param (
        [Parameter(Mandatory = $true)] [string]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId
    )

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

    return $adminRelationshipMissingAccessAssignmentInfo
}
