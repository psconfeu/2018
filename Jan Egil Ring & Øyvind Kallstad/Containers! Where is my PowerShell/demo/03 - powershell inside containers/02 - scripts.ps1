break #Safety net. This script is supposed to be run line by line interactively, not all at once.

#region PowerShell commands and scripts in Docker-files

<#

References from Docker documentation

RUN has 2 forms:

RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
RUN ["executable", "param1", "param2"] (exec form)

PowerShell example:
RUN pwsh -command Get-Uptime

The SHELL instruction allows the default shell used for the shell form of commands to be overridden. The default shell on Linux is ["/bin/sh", "-c"], and on Windows is ["cmd", "/S", "/C"]. The SHELL instruction must be written in JSON form in a Dockerfile.

The SHELL instruction can appear multiple times. Each SHELL instruction overrides all previous SHELL instructions, and affects all subsequent instructions. For example:

# Executed as powershell -command Write-Host hello
SHELL ["powershell", "-command"]
RUN Write-Host hello

# Executed as cmd /S /C echo hello
SHELL ["cmd", "/S", "/C"]
RUN echo hello

Source: https://docs.docker.com/engine/reference/builder/

#>

#cd ~\Documents\github\psconfeu2018-shared\docker

# Let`s have a look at a Docker-file where PowerShell is leveraged
Open-EditorFile -Path .\NanoDemoWebsite\Dockerfile

# Note: Remember to switch to Windows Containers before building the docker file (Linux is the default after installing Docker for Windows)
docker build NanoDemoWebsite -t psconfeu:nanodemowebsite --no-cache

# Test drive the image
$ContainerID = docker run -d --rm psconfeu:nanodemowebsite

docker ps

# Retrieve the container`s IP address
$ContainerIP = docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $ContainerID

# Launch the website running in the container from a web browser to verify it`s running
Start-Process -FilePath iexplore.exe -ArgumentList http://$ContainerIP

docker stop $ContainerID

#endregion

#region PowerShellGet - also available in PowerShell Core - can be used inside containers for downloading scripts either from the PowerShell Gallery or a local repository

Start-Process -FilePath powershell -ArgumentList "/c docker run -it microsoft/powershell:6.0.2-nanoserver-1709 pwsh"

Install-Script -Name Get-Weather -Scope CurrentUser
Get-Weather -City Hanover

#endregion