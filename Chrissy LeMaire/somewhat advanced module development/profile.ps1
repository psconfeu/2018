$content = @'
function prompt {
    "I $([char]9829) dbatools: "
}

Import-Module dbatools
. "þinsertinternalþ"
'@

$pathInternal = Resolve-Path .\importinternals.ps1
$content = $content -replace "þinsertinternalþ",$pathInternal
Set-Content -Path $profile -Value $content -Encoding UTF8
$cred = (Get-Credential foo)