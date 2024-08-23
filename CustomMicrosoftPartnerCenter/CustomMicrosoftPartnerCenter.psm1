<#
$public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$variables = @(Get-ChildItem -Path $PSScriptRoot\Variables\*.ps1 -ErrorAction SilentlyContinue)
$prod = @(Get-ChildItem -Path $PSScriptRoot\ProdV2\*.ps1 -ErrorAction SilentlyContinue)
$dev = @(Get-ChildItem -Path $PSScriptRoot\DevV2\*.ps1 -ErrorAction SilentlyContinue)

foreach ($function in @($public + $private + $prod + $dev))
{
    try
    {
        . $function.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($function.fullname): $_."
    }
}

foreach ($variable in $variables)
{
    try
    {
        . $variable.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import variable $($variable.fullname): $_."
    }
}

Export-ModuleMember -Function $public.basename -Variable GDAPAccess
#>

. "$PSScriptRoot\Public\AuthTokenManager.ps1"
. "$PSScriptRoot\Public\Get-CMPCAdminRelationship.ps1"
. "$PSScriptRoot\TempDev\Edit-CMPCAdminRelationship.ps1"
Export-ModuleMember -Function Get-CMPCAdminRelationship
Export-ModuleMember -Function Edit-CMPCAdminRelationship
Export-ModuleMember -TypeDefinition AuthTokenManager
$testmikael4 = "Skole2022!"
$yt2 = "egi"

$skole1 = "Mailand"
$skole2 = "Nannestad"
$skole3 = "Jessheim"
#$public = Get-ChildItem -Path "$($PSScriptRoot)\Public"

#foreach ($function in $collection) {
    <# $function is the current item #>
#}

Export-ModuleMember -Variable testmikael4,yt2,skole*