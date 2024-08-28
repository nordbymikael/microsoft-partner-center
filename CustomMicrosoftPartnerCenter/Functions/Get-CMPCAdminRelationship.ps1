function Get-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function retrieves information about an admin relationship.

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
        ConfirmImpact = "Medium",
        DefaultParameterSetName = "Default",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#get-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [System.String]$adminRelationshipId,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [System.Management.Automation.SwitchParameter]$extendedInformation
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if (!$adminRelationshipId)
        {
            $adminRelationshipCollection = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"
    
            if ($extendedInformation)
            {
                $allAdminRelationships = @()
    
                foreach ($adminRelationshipObject in $adminRelationshipCollection) {
                    $adminRelationship = @{
                        "@" = $adminRelationshipObject
                        accessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/accessAssignments"
                        operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/operations"
                        requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipObject.id)/requests"
                    }
                    $allAdminRelationships += $adminRelationship
                }
    
                return $allAdminRelationships
            }
            
            return $adminRelationshipCollection
        }
        else {
            $headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            $adminRelationshipObject = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)" -Headers $headers
            $adminRelationshipObject.PSObject.Properties.Remove("@odata.context")
    
            if ($extendedInformation)
            {
                $adminRelationship = @{
                    "@" = $adminRelationshipObject
                    AccessAssignments = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/accessAssignments"
                    Operations = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/operations"
                    Requests = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($adminRelationshipId)/requests"
                }
    
                return $adminRelationship
            }
            
            return $adminRelationshipObject
        }
    }

    end
    {

    }
}
