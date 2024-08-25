# Import functions from public folder
Get-ChildItem -Path "$($PSScriptRoot)\Public" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

# Import functions from helper functions folder
Get-ChildItem -Path "$($PSScriptRoot)\HelperFunctions" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}

# Import variables
Get-ChildItem -Path "$($PSScriptRoot)\Variables" -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}
Get-Variable -Scope Script | Where-Object {$_.Name -notlike "PSScriptRoot" -and $_.Name -notlike "MyInvocation"} | ForEach-Object {
    Export-ModuleMember -Variable $_.Name
}
