# escape=`
#FROM microsoft/aspnet:3.5-windowsservercore-10.0.14393.1198
FROM microsoft/iis
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# disable DNS cache so container addresses always fetched from Docker
RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord

RUN Remove-Website 'Default Web Site';

#RUN Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment,IIS-ASPNET45,IIS-BasicAuthentication,IIS-ClientCertificateMappingAuthentication,IIS-CommonHttpFeatures,IIS-DefaultDocument,IIS-DirectoryBrowsing,IIS-FTPExtensibility,IIS-FTPServer,IIS-FTPSvc,IIS-HealthAndDiagnostics,IIS-HttpCompressionStatic,IIS-HttpErrors,IIS-HttpLogging,IIS-HttpRedirect,IIS-HttpTracing,IIS-ISAPIExtensions,IIS-ISAPIFilter,IIS-LegacySnapIn,IIS-LoggingLibraries,IIS-Metabase,IIS-NetFxExtensibility45,IIS-Performance,IIS-RequestFiltering,IIS-RequestMonitor,IIS-Security,IIS-StaticContent,IIS-WebServer,IIS-WebServerRole,IIS-WindowsAuthentication,NetFx4Extended-ASPNET45

# Set up website: Pester
RUN New-Item -Path 'C:\inetpub\Pester' -Type Directory -Force; 

RUN New-Website -Name 'Pester' -PhysicalPath 'C:\inetpub\Pester' -Port 80 -Force; 

EXPOSE 80

COPY ["Pester", "/inetpub/Pester"]

RUN $path='C:\inetpub\Pester'; `
    $acl = Get-Acl $path; `
    $newOwner = [System.Security.Principal.NTAccount]('BUILTIN\IIS_IUSRS'); `
    $acl.SetOwner($newOwner); `
    dir -r $path | Set-Acl -aclobject  $acl
