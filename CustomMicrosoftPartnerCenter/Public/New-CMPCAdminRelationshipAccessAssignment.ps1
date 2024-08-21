function New-CMPCAdminRelationshipAccessAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [hashtable]$accessToken,
        [Parameter(Mandatory = $true)] [string]$adminRelationshipId,
        [Parameter(Mandatory = $false)] [string]$securityGroup,
        [Parameter(Mandatory = $false)] [array]$unifiedRoles,
        [Parameter(Mandatory = $false)] [switch]$usePredefinedUnifiedRoles
    )

    $headers = @{
        Authorization = "Bearer $(Unprotect-SecureString -secureString $accessToken.DelegatedAdminRelationship)"
    }
    $body = @{
        accessContainer = @{
            accessContainerId = $securityGroup # Seciruty group ID will be defined later
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = $unifiedRoles
        }
    }
    $accessAssignment = @()

    if ($usePredefinedUnifiedRoles)
    {
        foreach ($role in ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json))
        {
            $body.accessContainer["accessContainerId"] = $role.securityGroupId
            $body.accessDetails["unifiedRoles"] = @(@{roleDefinitionId = $role.roleDefinitionId})
            $accessAssignmentCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Headers $headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"
            $accessAssignment += $accessAssignmentCreation
        }
    }
    else {
        $accessAssignmentCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments" -Headers $headers -Body ($body | ConvertTo-Json -Depth 100) -ContentType "application/json"
        $accessAssignment += $accessAssignmentCreation
    }

    return $accessAssignment
}
