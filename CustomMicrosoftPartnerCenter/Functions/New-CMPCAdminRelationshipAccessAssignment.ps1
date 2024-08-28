function New-CMPCAdminRelationshipAccessAssignment {
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
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$adminRelationshipId,
        
        [Parameter(Mandatory = $false)] [System.String]$securityGroup,
        [Parameter(Mandatory = $false)] [ValidateCount(1, 72)] [System.Object[]]$unifiedRoles,
        [Parameter(Mandatory = $false)] [System.Management.Automation.SwitchParameter]$usePredefinedUnifiedRoles
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
    
    $headers = @{
        Authorization = "Bearer $($authTokenManager.GetValidToken())"
    }
    $adminRelationship = Invoke-WebRequest -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)?`$select=status" -Headers $headers
    
    switch ($adminRelationship.StatusCode) {
        200 {
            Continue
        }
        409 {
            throw "Cannot create a new access assignment on the relationship because the specified security group already has been assigned access to. Use the Edit-CMPCAdminRelationshipAccessAssignment cmdlet."
        }
        401 {
            Write-Warning -Message "Created a new access token for this session, because the current access token is expired. Renew your access token."
        }
    }
    
    switch (($adminRelationship.Content | ConvertFrom-Json).status) {
        "active" {
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
                    $body.accessContainer.accessContainerId = $role.securityGroupId
                    $body.accessDetails.unifiedRoles = @(@{roleDefinitionId = $role.roleDefinitionId})
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
        "terminationRequested" {
            throw "Cannot create a new access assignment on the relationship because the admin relationship is scheduled for termination."
        }
        "terminating" {
            throw "Cannot create a new access assignment on the relationship because the admin relationship is terminating."
        }
        "terminated" {
            throw "Cannot create a new access assignment on the relationship because the admin relationship has been terminated."
        }
        "created" {
            throw "Cannot create a new access assignment on the relationship because the admin relationship has not yet been locked for approval."
        }
        "approvalPending" {
            throw "Cannot create a new access assignment on the relationship because the admin relationship has not yet been approved by a customer."
        }
        default {
            throw "Something went wrong."
        }
    }
}
