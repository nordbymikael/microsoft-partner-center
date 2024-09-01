$TenantId = ""
$AppName = "PartnerCenterPowershellModule"

####################################################################################################
# Define the variables above and run the script
####################################################################################################

$Permissions = @("DelegatedAdminRelationship.Read.All")

if (-not (Get-InstalledModule -Name Microsoft.Graph -ErrorAction SilentlyContinue)) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
}

Connect-MgGraph -Scopes "Application.ReadWrite.All", "Directory.ReadWrite.All" -TenantId $TenantId

$App = New-MgApplication -DisplayName $AppName
$AppId = $App.AppId

foreach ($Permission in $Permissions) {
    $AppRole = Get-MgServicePrincipalAppRole -ServicePrincipalId $App.Id | Where-Object {$_.Value -eq $Permission}
    New-MgServicePrincipalAppRoleAssignment -PrincipalId $App.Id -ResourceId $AppRole.ResourceId -AppRoleId $AppRole.Id
}

$ServicePrincipal = New-MgServicePrincipal -AppId $AppId
foreach ($Permission in $Permissions) {
    $AppRole = Get-MgServicePrincipalAppRole -ServicePrincipalId $ServicePrincipal.Id | Where-Object {$_.Value -eq $Permission}
    New-MgServicePrincipalAppRoleAssignment -PrincipalId $ServicePrincipal.Id -ResourceId $AppRole.ResourceId -AppRoleId $AppRole.Id
}

# Create a client secret
$ClientSecret = New-MgApplicationPassword -ApplicationId $App.Id -DisplayName "ClientSecret" -EndDateTime (Get-Date).AddYears(1)

# Output the client ID, tenant ID, and client secret
$ClientId = $AppId
$ClientSecretValue = $ClientSecret.SecretText

Write-Host -Object "Client ID: $($ClientId)"
Write-Host -Object "Tenant ID: $($TenantId)"
Write-Host -Object "Client Secret: $($ClientSecretValue)"
