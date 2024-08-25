function New-CMPCAdminRelationship {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory = $false)] [string]$displayName,
        [Parameter(Mandatory = $false)] [string]$duration,
        [Parameter(Mandatory = $false)] [array]$unifiedRoles,
        [Parameter(Mandatory = $false)] [string]$autoExtendDuration,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedUnifiedRoles,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedVariables
    )

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

    $accessToken = $authTokenManager.GetValidToken()

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
            Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken)"
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
