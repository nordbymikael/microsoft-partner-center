function New-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function creates an admin relationship.

    .DESCRIPTION
    This function creates an admin relationship based either on parameters provided with the 
    This function validates the format of all parameters and also says if the unified roles values are nonexistent or incompatible with GDAP.
    
    There are many validation steps within this function and unexpected errors are often considered anomalies.
    A common unexpected error is the presence of invalid characters in the DisplayName.
    Another common unextected error is that the customer does not exist in Partner Center.

    .PARAMETER DisplayName
    This is the display name for the admin relationship.
    It has to be between 1 and 50 characters and might not support some characters.

    .PARAMETER Duration
    This is the duration of an admin relationship in days.
    Any value between 1 and 720 is accepted.
    The function automatically converts this value to the ISO 8601 format.

    .PARAMETER UnifiedRoles
    This is an array of strings with the GUIDs of built-in Entra roles.
    These roles will be added to the admin relationship and eligible for access assignments to security groups after the admin relationship becomes accepted by a customer.
    This parameter might be an array like @("xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx", "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" ...) or "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx",...

    .PARAMETER AutoExtendDuration
    This is the auto extend duration for the admin relationship.
    When the admin relationship expires, this is the amount of days that the admin relationship automatically extends itself by.
    Supported values are 0 and 180.

    .PARAMETER Customer
    This is the customer for which you want to reserve the admin relationship.
    The customer has to exist in Partner Center before this parameter becomes valid for the customer.

    .PARAMETER UsePredefinedVariables
    This parameter takes variables from the Configuration.ps1 file from the module.
    This parameter does not support to create the relationship for a specific customer.

    .INPUTS
    Inputs of the function

    .OUTPUTS
    Outputs of the function

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationship

    .NOTES
    Advanced explanation of the code flow

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text

    .EXAMPLE
    Cmdlet -parameter "parameter"
    Text
    #>

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
        [System.String]$DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidatePattern("^\d+$")]
        [ValidateScript({
            if ([int]$_ -ge 1 -and [int]$_ -le 720) {
                $true
            } else {
                throw "The value for Duration must be a number between 1 and 720."
            }
        })]
        [System.String]$Duration,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidateCount(1, 72)]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            foreach ($role in $_) {
                if ($role -in $CMPC_SupportedRoles)
                {
                    $true
                }
                else {
                    throw "The role `"$($role)`" in the UnifiedRoles parameter is either not an Entra built-in role or it exists but is incompatible with admin relationships. Remove the role and try again."
                }
            }
        })]
        [string[]]$UnifiedRoles,

        [Parameter(Mandatory = $false, ParameterSetName = "Direct")]
        [ValidatePattern("^(0|180)$")]
        [System.String]$AutoExtendDuration = "PT0S",

        [Parameter(Mandatory = $false, ParameterSetName = "Direct")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$Customer,

        [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationFile")]
        [ValidateScript({
            # Validate CMPC_AdminRelationshipUnifiedRoles
            try {
                foreach ($role in ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json))
                {
                    if (!([System.String]::IsNullOrEmpty($role.roleDefinitionId)) -and $role.roleDefinitionId -is [System.String] -and $role.roleDefinitionId -match "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
                    {
                        $true
                    }
                    if ($role.roleDefinitionId -notin $CMPC_SupportedRoles)
                    {
                        throw "The role `"$($role.roleDefinitionId)`" is either not an Entra built-in role or it exists but is incompatible with admin relationships. Remove the role and try again."
                    }
                }
            }
            catch {
                throw "Roles are not properly formatted. See the template file for reference."
            }

            # Validate CMPC_AdminRelationshipDisplayName
            if (-not ([System.String]::IsNullOrEmpty($CMPC_AdminRelationshipDisplayName) -and $CMPC_AdminRelationshipDisplayName -is [System.String])) {
                throw "CMPC_AdminRelationshipDisplayName must be a string."
            }
            if ($CMPC_AdminRelationshipDisplayName.Length -lt 1 -or $CMPC_AdminRelationshipDisplayName.Length -gt 50) {
                throw "CMPC_AdminRelationshipDisplayName must have between 1 and 50 characters."
            }

            # Validate CMPC_AdminRelationshipDuration
            if (-not ([System.String]::IsNullOrEmpty($CMPC_AdminRelationshipDuration) -and $CMPC_AdminRelationshipDuration -is [System.String])) {
                throw "CMPC_AdminRelationshipDuration must be a string."
            }
            if ($CMPC_AdminRelationshipDuration -notmatch "^\d+$" -or ([int]$CMPC_AdminRelationshipDuration -lt 1 -or [System.Int32]$CMPC_AdminRelationshipDuration -gt 720)) {
                throw "The value for Duration must be a number between 1 and 720."
            }

            # Validate CMPC_AdminRelationshipAutoExtendDuration
            if (![System.String]::IsNullOrEmpty($CMPC_AdminRelationshipAutoExtendDuration -and $CMPC_AdminRelationshipAutoExtendDuration -notmatch "^(0|180)$")) {
                throw "AutoExtendDuration must be either `"0`" or `"180`"."
            }
        })]
        [System.Management.Automation.SwitchParameter]$UsePredefinedVariables
    )

    begin
    {
        Confirm-AccessTokenExistence

        $Body = @{
            accessDetails = @{
                unifiedRoles = @()
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "Direct")
        {
            foreach ($role in $UnifiedRoles)
            {
                $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role}
            }

            $Body.displayName = $DisplayName
            $Body.duration = "P$($Duration)D"

            if ($AutoExtendDuration -ne "PT0S")
            {
                # ISO 8601 format date
                $Body.autoExtendDuration = "P$($AutoExtendDuration)D"
            }
            if ($Customer)
            { #Not done, not properly formatted
                $Body.customer = @{}
                $Body.customer.tenantId = $Customer
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq "ConfigurationFile")
        {
            foreach ($role in ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json))
            {
                $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role.roleDefinitionId}
            }

            $Body.displayName = $CMPC_AdminRelationshipDisplayName
            $Body.duration = "P$($CMPC_AdminRelationshipDuration)D"

            if ($CMPC_AdminRelationshipAutoExtendDuration)
            {
                # ISO 8601 format date
                $Body.autoExtendDuration = "P$($CMPC_AdminRelationshipAutoExtendDuration)D"
            }
        }

        $Headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
    }

    process
    {
        try {
            # Create the admin relationship
            $AdminRelationshipCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships" -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 100) -ContentType "application/json"
        }
        catch [System.Net.WebException] {
            $response = $_.Exception.Response
            $statusCode = [int]$response.StatusCode

            switch ($statusCode) {
                409 {
                    throw "Conflict error 409, there is already an admin relationship with the provided DisplayName. Choose another DisplayName."
                }
                400 {
                    throw "Bad request error 400, this an unexpected error but the issue might be in the DisplayName parameter. Try a different name to see if some characters that you provided are not supported by admin relationships. Another common error is that the customer tenant ID does not exist in Partner Center."
                }
                default {
                    throw "An unexpected error occurred: $($_)"
                }
            }
        }

        try {
            $Body = @{
                action = "lockForApproval"
            }

            # Lock the admin relationship for approval
            Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)/requests" -Headers $Headers -Body ($Body | ConvertTo-Json) -ContentType "application/json" > $null
        }
        catch {
            $response = $_.Exception.Response
            $statusCode = [int]$response.StatusCode

            switch ($statusCode) {
                405 {
                    # This code block should normally not run, but if it for some reason does, throttling may be the cause
                    Start-Sleep -Milliseconds 5000
                    Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)/requests" -Headers $Headers -Body ($Body | ConvertTo-Json) -ContentType "application/json" > $null

                    Write-Warning -Message "Method Not Allowed error 405, the admin relationship was successfully created and locked for approval but the code flow thought the admin relationship does not exist. You may be throttled."
                }
                default {
                    throw "An unexpected error occurred: $($_)"
                }
            }
        }
        
        $AdminRelationship = @{
            "@" = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)" -Headers $Headers
            InvitationLink = "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($adminRelationshipCreation.id)"
        }
    }

    end
    {
        return $AdminRelationship
    }
}
