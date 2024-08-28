[System.String]$tenantId = ""
[System.String]$clientId = ""
[System.String]$clientSecret = ""

[System.String]$adminRelationshipId = ""

####################################################################################################
# Define the variables above and run the script
####################################################################################################

Import-Module CustomMicrosoftPartnerCenter
Connect-CMPC -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret

$requiredAccessAssignments = $CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json
$missingAccessAssignments = @()

$activeAccessAssignments = Get-CMPCAdminRelationshipAccessAssignment -adminRelationshipId $adminRelationshipId | Where-Object {$_.status -eq "active"}

foreach ($accessAssignment in $requiredAccessAssignments)
{
    if ($accessAssignment.SecurityGroupId -notin $activeAccessAssignments.accessContainer.accessContainerId)
    {
        $missingAccessAssignments += @{
            SecurityGroupId = $accessAssignment.SecurityGroupId
            RoleDefinitionId = $accessAssignment.RoleDefinitionId
            RoleDefinitionName = $accessAssignment.RoleDefinitionName
        }
    }
}

Write-Host -Object $missingAccessAssignments

Disconnect-CMPC
