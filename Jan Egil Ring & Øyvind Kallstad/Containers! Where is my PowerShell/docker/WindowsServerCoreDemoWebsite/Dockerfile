# escape=`
FROM microsoft/iis:windowsservercore-10.0.14393.1715
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest https://aka.ms/dotnetcore.2.0.0-windowshosting -OutFile C:\Windows\Temp\DotNetCore.2.0.0-WindowsHosting.exe
RUN Start-Process -FilePath C:\Windows\Temp\DotNetCore.2.0.0-WindowsHosting.exe -ArgumentList '/install','/quiet','/norestart' -Wait
RUN Remove-Item -Force C:\Windows\Temp\DotNetCore.2.0.0-WindowsHosting.exe

RUN dir c:/inetpub/wwwroot | Remove-Item -Force

RUN $path='C:\inetpub\wwwroot'; `
    $acl = Get-Acl $path; `
    $newOwner = [System.Security.Principal.NTAccount]('BUILTIN\IIS_IUSRS'); `
    $acl.SetOwner($newOwner); `
    dir -r $path | Set-Acl -aclobject  $acl

RUN Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force

RUN Save-Module -Name UniversalDashboard -Path C:\inetpub\wwwroot -Force

RUN $dir = dir C:\inetpub\wwwroot -Directory | Foreach-Object { dir $PSItem.FullName -Directory }; dir $dir.FullName | Copy-Item -Destination C:\inetpub\wwwroot -Recurse

COPY ["dashboard.ps1", "c:/inetpub/wwwroot/dashboard.ps1"]

COPY ["license.lic", "c:/inetpub/wwwroot/net451/license.lic"]

EXPOSE 80