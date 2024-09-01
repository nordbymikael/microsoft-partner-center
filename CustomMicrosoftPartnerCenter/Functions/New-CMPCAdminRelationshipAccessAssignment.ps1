function New-CMPCAdminRelationshipAccessAssignment {
    #REQUIRES -Version 4.0
    #REQUIRES -Modules Microsoft.PowerShell.Utility

    <#
    .SYNOPSIS
    This function creates a new access assignment on an admin relationship.

    .DESCRIPTION

    .PARAMETER AdminRelationshipId
    Specify the admin relationship ID of the admin relationship that you want to create an access assignment on.

    .PARAMETER AdminRelationshipDisplayName
    Specify the admin relationship display name of the admin relationship that you want to create an access assignment on.

    .PARAMETER SecurityGroup
    Specify the security group that you want to assign access to.

    .PARAMETER UnifiedRoles
    Specify the Entra roles associated with the admin relationship, that you want to give a security group access to.
    
    .PARAMETER UsePredefinedVariables
    Use this parameter if you have used the Configuration.ps1 file to specify the roles and their associated security groups.
    Be sure to properly format the JSON object.
    Every row should have both security group ID and role definition ID defined.

    .INPUTS
    The first input is either the admin relationship id or the admin relationship display name.
    Afterwards, specify the security group to assign access to followed by a list of roles to assign to the security group.
    Alternatively, use the UsePredefinedVariables switch parameter to assign roles to security groups based on the Configuration.ps1 file.

    .OUTPUTS
    The output of the function is whether the access assignment was created successfully or if it failed.

    .LINK
    Online version: https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationshipaccessassignment

    .NOTES
    This function first validates that the roles that you try to create an access assignment on, are also present in the admin relationship object.
    Also the formatting of the parameters is properly checked.
    Afterwards, if the admin relationship display name parameter is used, the function retrieves all the admin relationships and finds the admin relationship ID.
    The admin relationship ID is therefore used anyways, but the use of admin relationship display name triggers an extra process of retrieving the admin relationship ID.
    If the admin relationship ID parameter is used, this extra process is not started.

    Afterwards, the admin relationship status is retrieved and the function decides whether to proceed or to not proceed because the admin relationship might not be active.
    If the admin relationship is not active, an error is returned saying that the admin relationship cannot have access assignments.

    If the admin relationship is active, either the logic using the Configuration.ps1 file is used or the logic using the security group and unified roles parameters.
    
    If the UsePredefinedVariables parameter is used, failed access assignments only return a warning.
    This is because this parameter should only be used with admin relationships that are created with the roles in the same Configuration.ps1 file, and any conflict with existing access assignments should only occur if this specific access assignment has been created in advance.
    Manual user interference with the configured access assignments in Configuration.ps1 is not catched and has to be scripted separately.

    If the security group and unified roles parameters are used, this function will create a new access assignment on the admin relationship using the specified security group and roles.
    A 409 conflict error is quite common, indicating that another active access assignment already exists.
    In this situation, the function writes a warning, retrieves the roles from the current active access assignment and merges the current roles with the new roles.
    Afterwards, the current active access assignment is deleted and a new access assignment is created with all the previous and new roles.
    The patch method could be used instead of deleting and creating the access assignment and would be faster, but the creation of a whole new access assignment creates a new log entry in the access assignments object in the relationship, so for logging purposes it is best practice to recreate the access assignment.

    .EXAMPLE
    New-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -SecurityGroup "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -UnifiedRoles "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to create an access assignment on an admin relationship using the admin relationship ID.
    In this example, three roles are assigned, but feel free to include up to 73 of the supported roles.

    .EXAMPLE
    New-CMPCAdminRelationshipAccessAssignment -AdminRelationshipDisplayName "SomeRandomAdminRelationshipName" -SecurityGroup "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -UnifiedRoles "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    This example shows how to create an access assignment on an admin relationship using the admin relationship display name.
    This works because every admin relationship has a unique name. This function does not work much differently with this parameter. An extra process to find the admin relationship id of the specified admin relationship name is run and this might take longer time because every admin relationship is retrieved in the background for the check.
    In this example, three roles are assigned, but feel free to include up to 73 of the supported roles.

    .EXAMPLE
    New-CMPCAdminRelationshipAccessAssignment -AdminRelationshipId "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx" -UsePredefinedVariables
    This example shows how to create an access assignment on an admin relationship using the admin relationship ID and the predefined "role-group" relationship in the Configuration.ps1 file.

    .EXAMPLE
    New-CMPCAdminRelationshipAccessAssignment -AdminRelationshipDisplayName "SomeRandomAdminRelationshipName" -UsePredefinedVariables
    This example shows how to create an access assignment on an admin relationship using the admin relationship display name and the predefined "role-group" relationship in the Configuration.ps1 file.
    #>
    
    [CmdletBinding(
        ConfirmImpact = "High",
        DefaultParameterSetName = "AdminRelationshipIdWithParameters",
        HelpUri = "https://github.com/nordbymikael/microsoft-partner-center#new-cmpcadminrelationshipaccessassignment",
        SupportsPaging = $false,
        SupportsShouldProcess = $true,
        PositionalBinding = $true
    )]

    param (
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipIdWithParameters", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipIdWithConfigurationFile", ValueFromPipeline = $true)]
        [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
        [ValidateScript({
            Confirm-AdminRelationshipExistence -AdminRelationshipId $_
        })]
        [System.String]$AdminRelationshipId,

        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipDisplayNameWithParameters", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipDisplayNameWithConfigurationFile", ValueFromPipeline = $true)]
        [ValidateCount(1, 50)]
        [ValidateScript({
            Get-AdminRelationshipIdFromName -AdminRelationshipDisplayName $_ > $null
        })]
        [System.String]$AdminRelationshipDisplayName,
        
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipIdWithParameters")]
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipDisplayNameWithParameters")]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [System.String]$SecurityGroup,

        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipIdWithParameters")]
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipDisplayNameWithParameters")]
        [ValidateCount(1, 73)]
        [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
        [ValidateScript({
            $UnifiedRoles = $_

            Confirm-AccessTokenExistence

            $Headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            
            $AdminRelationshipAccessDetails = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)?`$select=accessDetails" -Headers $Headers

            foreach ($role in $UnifiedRoles) {
                if ($role -notin $AdminRelationshipAccessDetails.accessDetails.unifiedRoles.roleDefinitionId)
                {
                    throw "The role `"$($role)`" in the UnifiedRoles parameter is not a valid role for the specified admin relationship. Remove the role and try again."
                }
                else {
                    $true
                }
            }
        })]
        [System.String[]]$UnifiedRoles,

        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipIdWithConfigurationFile")]
        [Parameter(Mandatory = $true, ParameterSetName = "AdminRelationshipDisplayNameWithConfigurationFile")]
        [ValidateScript({
            Confirm-AccessTokenExistence

            $Headers = @{
                Authorization = "Bearer $($authTokenManager.GetValidToken())"
            }
            
            $AdminRelationshipAccessDetails = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)?`$select=accessDetails" -Headers $Headers

            try {
                foreach ($role in ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json))
                {
                    if (!([System.String]::IsNullOrEmpty($role.roleDefinitionId)) -and $role.roleDefinitionId -is [System.String] -and $role.roleDefinitionId -match "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
                    {
                        $true
                    }
                    else {
                        throw "Roles are not properly formatted. See the template file for reference."
                    }

                    if ($role -notin $AdminRelationshipAccessDetails.accessDetails.unifiedRoles.roleDefinitionId)
                    {
                        throw "The role `"$($role)`" from the variable CMPC_AdminRelationshipUnifiedRoles is not a valid role for the specified admin relationship. Remove the role and try again."
                    }
                    else {
                        $true
                    }
                }
            }
            catch {
                throw "Roles are not properly formatted. See the template file for reference."
            }
        })]
        [System.Management.Automation.SwitchParameter]$usePredefinedVariables
    )

    begin
    {
        Confirm-AccessTokenExistence
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -contains "AdminRelationshipDisplayName")
        {
            $adminRelationshipId = Get-AdminRelationshipIdFromName -AdminRelationshipDisplayName $AdminRelationshipDisplayName
        }

        $Headers = @{
            Authorization = "Bearer $($authTokenManager.GetValidToken())"
        }
        $adminRelationship = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)?`$select=status" -Headers $Headers

        switch ($adminRelationship.status) {
            "active" {
                $Body = @{
                    accessContainer = @{
                        accessContainerId = "" # Will be defined later
                        accessContainerType = "securityGroup"
                    }
                    accessDetails = @{
                        unifiedRoles = @()
                    }
                }
            
                if ($PSCmdlet.ParameterSetName -contains "ConfigurationFile")
                {
                    foreach ($role in ($CMPC_AdminRelationshipUnifiedRoles | ConvertFrom-Json))
                    {
                        $Body.accessContainer.accessContainerId = $role.securityGroupId
                        $Body.accessDetails.unifiedRoles = @(@{roleDefinitionId = $role.roleDefinitionId})
                        
                        try {
                            Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments" -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 100) -ContentType "application/json"
                            Write-Host -Object "Successfully created the new access assignment for the security group `"$($SecurityGroup)`"."
                        }
                        catch {
                            Write-Warning -Message "An access assignment for the security group `"$($SecurityGroup)`" already exists."
                        }
                    }
                }
                elseif ($PSCmdlet.ParameterSetName -contains "Parameters") {
                    $Body.accessContainer.accessContainerId = $SecurityGroup

                    foreach ($role in $UnifiedRoles)
                    {
                        $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role}
                    }

                    try {
                        $accessAssignmentCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments" -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 100) -ContentType "application/json"
                        Write-Host -Object "Successfully created the new access assignment."
                    }
                    catch [System.Net.WebException] {
                        $response = $_.Exception.Response
                        $statusCode = [System.Int32]$response.StatusCode
            
                        switch ($statusCode) {
                            409 {
                                Write-Warning -Message "Conflict error 409, there is already an active access assignment with the provided security group. Trying to delete existing access assignment and create a new access assignment with both the old and new roles..."
                                
                                $DeleteHeaders = @{
                                    Authorization = "Bearer $($authTokenManager.GetValidToken())"
                                }
                                $ExistingAccessAssignment = Get-AllGraphAPIResponses -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments?`$select=accessContainer,status,id,@odata.etag" | Where-Object {$_.accessContainer.accessContainerId -eq $SecurityGroup} | Where-Object {$_.status -eq "active"}

                                if ($null -eq $ExistingAccessAssignment)
                                {
                                    throw "An unexpected error occurred: $($_)"
                                }

                                $DeleteHeaders."If-Match" = $ExistingAccessAssignment."@odata.etag"
                                Invoke-RestMethod -Method "Delete" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments/$($ExistingAccessAssignment.id)" -Headers $DeleteHeaders > $null
                                
                                # Sleeping to give time for the previous access assignment to end
                                Start-Sleep -Milliseconds 5000

                                $Body.accessDetails.unifiedRoles = @()
                                $OldRoles = $ExistingAccessAssignment.accessDetails.unifiedRoles.roleDefinitionId
                                $AllRoles = $OldRoles + $UnifiedRoles
                                $UniqueRoles = $AllRoles | Select-Object -Unique

                                foreach ($role in $UniqueRoles)
                                {
                                    $Body.accessDetails.unifiedRoles += @{"roleDefinitionId" = $role}
                                }

                                try {
                                    $accessAssignmentCreation = Invoke-RestMethod -Method "Post" -Uri "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$($AdminRelationshipId)/accessAssignments" -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 100) -ContentType "application/json"
                                    Write-Host -Object "Successfully created the new access assignment."
                                }
                                catch {
                                    throw "An unexpected error occurred: $($_)"
                                }
                            }
                            400 {
                                throw "Bad request error 400, an unexpected error occurred: $($_)"
                            }
                            default {
                                throw "An unexpected error occurred: $($_)"
                            }
                        }
                    }
                }
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

    end
    {

    }
}
