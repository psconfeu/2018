Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') | ForEach-Object {
    . $_.FullName
}

if (-not (Get-Command -Name docker -ErrorAction SilentlyContinue)) {

    Write-Warning -Message 'Docker is not available, PSDockerTools commands won`t function correctly without Docker installed. Docker is available from docker.com'

}

Update-FormatData -PrependPath (Join-Path -Path $PSScriptRoot -ChildPath 'PSDockerTools.ps1xml')