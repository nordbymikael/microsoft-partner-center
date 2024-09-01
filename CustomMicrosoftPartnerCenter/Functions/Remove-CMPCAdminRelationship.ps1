function Remove-CMPCAdminRelationship {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function ends an active or created admin relationship.

    .DESCRIPTION
    Provide either the display name or the ID of the admin relationship to end it.

    .PARAMETER AdminRelationshipId
    The admin relationship ID of the admin relationship you want to end.

    .PARAMETER AdminRelationshipDisplayName
    The admin relationship display name of the admin relationship you want to end.

    .INPUTS
    The input is either the admin relationship ID or the display name of the admin relationship.

    .OUTPUTS
    The output is a string indicating that the admin relationship has either been ended or that the admin relationship is already ended.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationship

    .NOTES
    As an extra step, if you use the admin relationship display name, the function finds the admin relationship ID which will be used by the API.
    Afterwards, the admin relationship object is retrieved.
    If the status is one of the statuses associated with a terminated relationship, the function will say that the admin relationship is already ended.
    If the status is active, the admin relationship becomes terminated.
    If the status is created, the admin relationship becomes completely deleted and will not appear in the overview of all admin relationships anymore.

    .EXAMPLE
    Remove-CMPCAdminRelationship -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example terminates an admin relationship based on the admin relationship ID.

    .EXAMPLE
    Remove-CMPCAdminRelationship -AdminRelationshipDisplayName "SomeRandomDisplayName"
    This example terminates an admin relationship based on the admin relationship display name.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "UsingId",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#remove-cmpcadminrelationship",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]
    
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "UsingId")]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$AdminRelationshipId,

        [Parameter(Mandatory = $true, ParameterSetName = "UsingDisplayName")]
        [ValidateCount(1, 50)]
        [ValidateScript({
            Get-AdminRelationshipIdFromName -AdminRelationshipDisplayName $AdminRelationshipDisplayName > $null
        })]
        [System.String]$AdminRelationshipDisplayName
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'UsingDisplayName')
        {
            $AdminRelationshipId = Get-AdminRelationshipIdFromName -AdminRelationshipDisplayName $AdminRelationshipDisplayName
        }

        $headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
        $AdminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)?`$select=@odata.etag,status" -Headers $headers

        switch ($AdminRelationship.status)
        {
            "active" {
                $body = @{
                    action = "terminate"
                }
                
                Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/requests" -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json" > $null
                
                Write-Host -Object "Ended the admin relationship with the id $($AdminRelationshipId)."
            }
            "created" {
                $headers."If-Match" = $AdminRelationship."@odata.etag"

                Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)" -Headers $headers > $null

                Write-Host -Object "Ended the admin relationship with the id $($AdminRelationshipId)."
            }
            "approvalPending" {
                return "The admin relationship with id $($AdminRelationshipId) cannot be ended because it has the `"approvalPending`" status. Accept the admin relationship before removing it."
            }
            default {
                return "The admin relationship with id $($AdminRelationshipId) has already ended."
            }
        }
    }

    end
    {
        
    }
}
