FROM microsoft/windowsservercore:1709
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ["DSCContainerDemo.ps1", "c:/DSCContainerDemo.ps1"]

RUN . c:\DSCContainerDemo.ps1; PrintSpooler -OutputPath 'C:\'

RUN Start-DscConfiguration -Path c:\ -Wait -Verbose -Force