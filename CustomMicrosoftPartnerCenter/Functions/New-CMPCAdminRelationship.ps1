function New-CMPCAdminRelationship {
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "Direct",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidateCount(1, 50)]
        [System.String]$displayName,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [System.String]$duration,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidateCount(1, 72)]
        [System.Object[]]$unifiedRoles,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [System.String]$autoExtendDuration,

        [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationFile")]
        [System.Management.Automation.SwitchParameter]$usePredefinedUnifiedRoles,

        [Parameter(Mandatory = $false, ParameterSetName = "ConfigurationFile")]
        [System.Management.Automation.SwitchParameter]$usePredefinedVariables
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        
    }

    end
    {
    
    }
    

    if ($usePredefinedVariables)
    {
        if ($CMPC_AdminRelationshipDisplayName)
        {
            $displayName = $CMPC_AdminRelationshipDisplayName
        }
        if ($CMPC_AdminRelationshipDuration)
        {
            $duration = $CMPC_AdminRelationshipDuration
        }
        if ($CMPC_AdminRelationshipAutoExtendDuration)
        {
            $autoExtendDuration = $CMPC_AdminRelationshipAutoExtendDuration
        }
    }

    if (!$displayName -or !$duration)
    {
        throw "At least one of the mandaroty parameters is not provided (displayName or duration)."
    }
    elseif (!$usePredefinedUnifiedRoles -and !$unifiedRoles)
    {
        throw "When the usePredefinedUnifiedRoles parameter is not used, the unifiedRoles parameter is mandatory."
    }
    elseif ($usePredefinedUnifiedRoles -and $unifiedRoles)
    {
        throw "The unifiedRoles and usePredefinedUnifiedRoles parameters cannot be used together."
    }

    try {
        $unifiedRolesArray = if ($usePredefinedUnifiedRoles) {
            ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json) | ForEach-Object { @{ roleDefinitionId = $_.roleDefinitionId } }
        }
        else {
            $unifiedRoles
        }
        
        $body = @{
            displayName = $displayName
            duration = $duration
            accessDetails = @{
                unifiedRoles = $unifiedRolesArray
            }
        }
        
        if ($autoExtendDuration) {
            $body.autoExtendDuration = $autoExtendDuration
        }
    }
    catch {
        throw "Something went wrong while formatting the unifiedRoles from the pre-defined object (`$CMPC_AdminRelationshipUnifiedRoles).`nException: $($_.Exception.Message)"
    }

    try {
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    
        # Body is defined earlier
        $adminRelationshipCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships" -Headers $headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"
        
        $body = @{
            action = "lockForApproval"
        }
        Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)/requests" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null

        $adminRelationship = @{
            "@" = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)" -Headers $headers
            invitationLink = "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($adminRelationshipCreation.id)"
        }
        
        return $adminRelationship
    }
    catch {
        throw "Authorization failed or bad request.`nException: $($_.Exception.Message)"
    }


}
