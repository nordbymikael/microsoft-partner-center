function Edit-CMPCAdminRelationship {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [array]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [array]$unifiedRoles,
        [Parameter(Mandatory = $false)] [string]$autoExtendDuration,
        [Parameter(Mandatory = $false)] [string]$customerTenantId,
        [Parameter(Mandatory = $false)] [string]$displayName,
        [Parameter(Mandatory = $false)] [string]$duration,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedUnifiedRoles,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedVariables
    )
    #ferdig, må testes
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

    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }
    $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers

    switch ($adminRelationship.status)
    {
        "active" {
            if ($headers.Keys -contains "customer" -or $headers.Keys -contains "duration" -or $headers.Keys -contains "displayName") {
                return "Some of the requested changes are not supported beucase the admin relationship has the active status."
            }
            if ($headers.accessDetails.unifiedRoles -notcontains "") {
                <# Action to perform if the condition is true #>
            }
            $headers."If-Match" = $adminRelationship."@odata.etag"
            Invoke-WebRequest -Method "Patch" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null

            return "Successfully changed the admin relationship."
        }
        "created" {
            
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
