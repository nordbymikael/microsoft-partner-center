$public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$variables = @(Get-ChildItem -Path $PSScriptRoot\Variables\*.ps1 -ErrorAction SilentlyContinue)

foreach ($function in @($public + $private))
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
