function New-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function creates an admin relationship.

    .DESCRIPTION
    This function creates an admin relationship based either on parameters provided with the 
    This function validates the format of all parameters and also says if the unified roles values are nonexistent or incompatible with GDAP.
    
    There are many validation steps within this function and unexpected errors are rare.
    A common unexpected error is the presence of invalid characters in the DisplayName.

    This function does not yet support to create the relationship for a specific customer.

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

    .PARAMETER UsePredefinedVariables
    This parameter takes variables from the Configuration.ps1 file from the module.

    .INPUTS
    The inputs of the function are the display name of the admin relationship, the duration of the admin relationship and the unified roles associated with the admin relationship.
    Optionally, you can specify the auto extend duration to automatically extend the admin relationship.

    All these parameters can be predefined in the configuration file for this module. The formatting is properly checked.

    .OUTPUTS
    The output of the function is either an error with a description of what you have to change, or a successful response in a hashtable.
    The hashtable contains an URL that you can send to the customer's Global Administrator for approval, and the general admin relationship information.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationship

    .NOTES
    First, all the parameters are defined and properly checked for any incorrect formatting.
    The only exception is the check if the specified DisplayName is already used for another admin relationship, but if this is the case then the conflict error 409 is catched later and says that the specified DisplayName cannot be used.
    After the validation process, the function creates the admin relationship, and if no errors are present the admin relationship is automatically locked for approval.
    A simple throttling check is also implemented for the lockForApproval request. If the first try responss with a 405 status code, then the command is retried after 5000 milliseconds.
    The response is the general information about the admin relationship, as well as the invitation link that you can send to the customer.
    A terminating error is thrown if something went wrong.

    .EXAMPLE
    New-CMPCAdminRelationship -DisplayName "AdminRelationshipNameTest" -Duration "720" -UnifiedRoles "194ae4cb-b126-40b2-bd5b-6091b380977d","62e90394-69f5-4237-9190-012177145e10"
    This example shows how to create a new admin relationship with the name "AdminRelationshipNameTest", 720 days duration and the Security Administrator role and the Global Administrator role (not recommended, choose roles with less privilege).
    Since the UnifiedRoles is a comma separated list of strings (an array), you can add more roles by adding a comma and a new string.

    .EXAMPLE
    New-CMPCAdminRelationship -DisplayName "AdminRelationshipNameTest" -Duration "720" -UnifiedRoles "194ae4cb-b126-40b2-bd5b-6091b380977d" -AutoExtendDuration "180"
    This example shows how to create a new admin relationship with the Security Administrator role and how to enable auto extention by 180 days.
    Auto extention cannot be used with the Global Administrator role.

    .EXAMPLE
    New-CMPCAdminRelationship -UsePredefinedVariables
    This example shows how to create a new admin relationship using the predefined variables from the configuration file within the module.
    Be careful with the formatting when using this parameter. The function will detect any formatting errors.
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
        [ValidateScript({
            Get-AdminRelationshipIdFromName -AdminRelationshipDisplayName $_ > $null
        })]
        [System.String]$DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidatePattern("^\d+$")]
        [ValidateScript({
            if ([System.Int32]$_ -ge 1 -and [System.Int32]$_ -le 720) {
                $true
            } else {
                throw "The value for Duration must be a number between 1 and 720."
            }
        })]
        [System.String]$Duration,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Direct")]
        [ValidateCount(1, 73)]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            $UnifiedRoles = $_

            foreach ($role in $UnifiedRoles) {
                if ($role -in $CMPC_SupportedRoles)
                {
                    $true
                }
                else {
                    throw "The role `"$($role)`" in the UnifiedRoles parameter is either not an Entra built-in role or it exists but is incompatible with admin relationships. Remove the role and try again."
                }
            }

            if ("62e90394-69f5-4237-9190-012177145e10" -in $UnifiedRoles -and $AutoExtendDuration -ne "PT0S")
            {
                throw "Admin relationships with the Global Administrator role cannot be auto extended. Remove the Global Administrator role from the UnifiedRoles or remove the AutoExtendDuration."
            }
        })]
        [System.String[]]$UnifiedRoles,

        [Parameter(Mandatory = $false, ParameterSetName = "Direct")]
        [ValidatePattern("^(0|180)$")]
        [System.String]$AutoExtendDuration = "PT0S",

        <#
        Not added support for binding admin relationships to customers because for data validation purposes it is required to use the Microsoft Partner Center API which I do not have open access to.
        Both display name and tenant ID are required, but to make the function user friendly I want to only require the tenant ID. Because of the API issue, I did not have the opportunity to implement this.

        [Parameter(Mandatory = $false, ParameterSetName = "Direct")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$CustomerTenantId
        #>

        [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationFile")]
        [ValidateScript({
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

            if (-not ([System.String]::IsNullOrEmpty($CMPC_AdminRelationshipDisplayName) -and $CMPC_AdminRelationshipDisplayName -is [System.String])) {
                throw "CMPC_AdminRelationshipDisplayName must be a string."
            }
            if ($CMPC_AdminRelationshipDisplayName.Length -lt 1 -or $CMPC_AdminRelationshipDisplayName.Length -gt 50) {
                throw "CMPC_AdminRelationshipDisplayName must have between 1 and 50 characters."
            }

            if (-not ([System.String]::IsNullOrEmpty($CMPC_AdminRelationshipDuration) -and $CMPC_AdminRelationshipDuration -is [System.String])) {
                throw "CMPC_AdminRelationshipDuration must be a string."
            }
            if ($CMPC_AdminRelationshipDuration -notmatch "^\d+$" -or ([int]$CMPC_AdminRelationshipDuration -lt 1 -or [System.Int32]$CMPC_AdminRelationshipDuration -gt 720)) {
                throw "The value for Duration must be a number between 1 and 720."
            }

            if (![System.String]::IsNullOrEmpty($CMPC_AdminRelationshipAutoExtendDuration -and $CMPC_AdminRelationshipAutoExtendDuration -notmatch "^(0|180)$")) {
                throw "AutoExtendDuration must be either `"0`" or `"180`"."
            }
            if ("62e90394-69f5-4237-9190-012177145e10" -in $CMPC_AdminRelationshipUnifiedRoles.roleDefinitionId -and $CMPC_AdminRelationshipAutoExtendDuration -match "^(0|180)$")
            {
                throw "Admin relationships with the Global Administrator role cannot be auto extended. Remove the Global Administrator role from the UnifiedRoles or remove the AutoExtendDuration."
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
            $statusCode = [System.Int32]$response.StatusCode

            switch ($statusCode) {
                409 {
                    throw "Conflict error 409, there is already an admin relationship with the provided DisplayName. Choose another DisplayName."
                }
                400 {
                    throw "Bad request error 400, this an unexpected error but the issue might be in the DisplayName parameter. Try a different name to see if some characters that you provided are not supported by admin relationships."
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
            $statusCode = [System.Int32]$response.StatusCode

            switch ($statusCode) {
                405 {
                    # This code block should normally not run, but if it for some reason does, throttling may be the cause
                    Start-Sleep -Milliseconds 5000
                    
                    try {
                        Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipCreation.id)/requests" -Headers $Headers -Body ($Body | ConvertTo-Json) -ContentType "application/json" > $null
                        Write-Warning -Message "Method Not Allowed error 405, the admin relationship was successfully created and locked for approval but the code flow thought the admin relationship does not exist. You may be throttled."
                    }
                    catch {
                        throw "An unexpected error occurred: $($_)"
                    }

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
