$path = (Get-Module PasswordEndpoint -ListAvailable)[0].PrivateData['StoragePath']

if (-not (Test-Path $path))
{
    New-Item -ItemType Directory -Path $path
}
