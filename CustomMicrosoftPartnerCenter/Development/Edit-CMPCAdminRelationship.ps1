function Edit-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    Easy description of the function

    .DESCRIPTION
    Advanced description of the function

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .PARAMETER parametername
    Description of the parameter

    .INPUTS
    Inputs of the function

    .OUTPUTS
    Outputs of the function

    .LINK
    Online version: url

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
        DefaultParameterSetName = "Parameters",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#edit-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Parameters", ValueFromPipeline = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$adminRelationshipId,

        [Parameter(Mandatory = $false, ParameterSetName = "Parameters")]
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
        [System.String[]]$unifiedRoles,

        [Parameter(Mandatory = $false, ParameterSetName = "Parameters")]
        [ValidatePattern("^(0|180)$")]
        [System.String]$AutoExtendDuration,

        <#
        [Parameter(Mandatory = $false, ParameterSetName = "Parameters")]
        [System.String]$customerTenantId,
        #>

        [Parameter(Mandatory = $false, ParameterSetName = "Parameters")]
        [System.String]$displayName,

        [Parameter(Mandatory = $false, ParameterSetName = "Parameters")]
        [System.String]$duration
    )
    
    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
        $body = @{}

        if ($unifiedRoles)
        {
            $body.accessDetails = @{unifiedRoles = @()}
            
            foreach ($role in $UnifiedRoles)
            {
                $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role}
            }
        }
        <#
        if ($customerTenantId)
        {
            $body.customer = @{tenantId = $customerTenantId}
        }
        #>
        if ($autoExtendDuration)
        {
            $body.autoExtendDuration = $autoExtendDuration
        }
        if ($duration)
        {
            $body.duration = $duration
        }
        if ($displayName)
        {
            $body.displayName = $displayName
        }

        $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
        $headers."If-Match" = $adminRelationship."@odata.etag"

        switch ($adminRelationship.status)
        {
            "active" {
                if ($headers.Keys -contains "customer" -or $headers.Keys -contains "duration" -or $headers.Keys -contains "displayName") {
                    throw "Failed to update $($adminRelationshipId) becase at least one of the requested changes is not supported. The admin relationship has the active status."
                }
                try {
                    Invoke-WebRequest -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
                    Write-Output -InputObject "Successfully changed the admin relationship."
                }
                catch {
                    throw "Failed to update the admin relationship becase at least one of the requested changes is not properly formatted."
                }
            }
            "created" {
                try {
                    Invoke-WebRequest -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
                    Write-Host -Object "Successfully changed the admin relationship."
                }
                catch {
                    throw "Failed to update $($adminRelationshipId) becase at least one of the requested changes is not properly formatted."
                }
            }
            "terminationRequested" {
                throw "Cannot edit the admin relationship because the admin relationship is scheduled for termination."
            }
            "terminating" {
                throw "Cannot edit the admin relationship because the admin relationship is terminating."
            }
            "terminated" {
                throw "Cannot edit the admin relationship because the admin relationship has been terminated."
            }
            "approvalPending" {
                throw "Cannot edit the admin relationship because the admin relationship has not yet been approved by a customer."
            }
            default {
                throw "Something went wrong."
            }
        }
    }

    end
    {

    }
}
