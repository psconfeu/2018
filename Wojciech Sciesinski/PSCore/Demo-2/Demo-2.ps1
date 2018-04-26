#!pwsh

#Use methods provided by .Net Core
$([System.IO.Path]).GetMethods() | select-Object Name

#region Expected output

Name
----
ChangeExtension
GetDirectoryName
GetExtension
GetFileName
GetFileNameWithoutExtension
GetRandomFileName
HasExtension
Combine
Combine
Combine
Combine
GetRelativePath
GetInvalidFileNameChars
GetInvalidPathChars
GetFullPath
GetTempPath
GetTempFileName
IsPathRooted
GetPathRoot
ToString
Equals
GetHashCode
GetType

#endregion

[System.IO.Path]::AltDirectorySeparatorChar
[System.IO.Path]::DirectorySeparatorChar
[System.IO.Path]::VolumeSeparatorChar
[System.IO.Path]::PathSeparator


#Use declared variables
Get-ChildItem env: | Where-Object -FilterScript {$_.Name -match 'HOME' -or $_.Name -match 'PATH' } | Format-List

$PSVersionTable

Get-ChildItem -Path env:

Get-Variable


#Use dedicated cmdlets
Join-Path -Path $(Resolve-Path .) -ChildPath $(Get-ChildItem | Select-Object -First 1)

Split-Path $(Resolve-Path .) -Leaf
