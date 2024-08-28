function Edit-CMPCAdminRelationship {
    [CmdletBinding(
        ConfirmImpact = "High",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#edit-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.Object[]]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [ValidateCount(1, 72)] [System.Object[]]$unifiedRoles,
        [Parameter(Mandatory = $false)] [System.String]$autoExtendDuration,
        [Parameter(Mandatory = $false)] [System.String]$customerTenantId,
        [Parameter(Mandatory = $false)] [System.String]$displayName,
        [Parameter(Mandatory = $false)] [System.String]$duration,
        [Parameter(Mandatory = $false)] [System.Management.Automation.SwitchParameter]$usePredefinedUnifiedRoles,
        [Parameter(Mandatory = $false)] [System.Management.Automation.SwitchParameter]$usePredefinedVariables
    )
    #ferdig, må testes
    begin
    {
        Confirm-AccessTokenExistence
        
        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
        $body = @{}

        if ($unifiedRoles)
        {
            $body.accessDetails.unifiedRoles = $unifiedRoles
        }
        if ($customerTenantId)
        {
            $body.customer = @{tenantId=$customerTenantId}
        }
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
    }

    process
    {
        try {
            $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
            $headers."If-Match" = $adminRelationship."@odata.etag"
        }
        catch {
            throw "Failed to retrieve the admin relationship status and etag for precondition validation."
        }
    
        switch ($adminRelationship.status)
        {
            "active" {
                if ($headers.Keys -contains "customer" -or $headers.Keys -contains "duration" -or $headers.Keys -contains "displayName") {
                    throw "Failed to update $($adminRelationshipId) becase at least one of the requested changes is not supported. The admin relationship has the active status."
                }
                try {
                    Invoke-WebRequest -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
                    Write-Output -InputObject "Successfully changed the admin relationship $($adminRelationshipId)."
                }
                catch {
                    throw "Failed to update $($adminRelationshipId) becase at least one of the requested changes is not properly formatted."
                }
            }
            "created" {
                try {
                    Invoke-WebRequest -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
                    Write-Output -InputObject "Successfully changed the admin relationship $($adminRelationshipId)."
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
