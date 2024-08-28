# Import functions from public folder
Get-ChildItem -Path "$($PSScriptRoot)\Functions" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

# Import functions from helper functions folder
Get-ChildItem -Path "$($PSScriptRoot)\HelperFunctions" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    # No need to export the helper functions because they are not used by the end user
}

# Import variables
Get-ChildItem -Path "$($PSScriptRoot)\Configuration" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}
Get-Variable -Scope Script | Where-Object {$_.Name -notlike "PSScriptRoot" -and $_.Name -notlike "MyInvocation"} | ForEach-Object {
    Export-ModuleMember -Variable $_.Name
}
