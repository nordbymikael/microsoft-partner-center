function Get-AdminRelationshipIdFromName {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.String]$AdminRelationshipDisplayName
    )
    
    begin
    {

    }

    process
    {
        $AllAdminRelationships = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships?`$id,displayName"
        $AdminRelationshipId = ($AllAdminRelationships | Where-Object {$_.displayName -eq $AdminRelationshipDisplayName}).id

        if ($null -eq $AdminRelationshipId)
        {
            throw "The admin relationship with the specified display name does not exist."
        }

        return $AdminRelationshipId
    }
    
    end
    {
        
    }
}
