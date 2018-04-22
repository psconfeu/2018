configuration WebServerConfig
{
    param(
        [Parameter(Mandatory)]
        [hashtable]$ConfigData
    )
    
    Import-DscResource -ModuleName xWebAdministration

    $currentConfigName = $ExecutionContext.SessionState.Module.Name
    File "ConfigAppliedFile_$currentConfigName"
    {
        DestinationPath = "C:\dsc $currentConfigName applied.txt"
        Contents = Get-Date
        Type = 'File'
        Ensure = 'Present'
    }
    
    WindowsFeature IIS
    {
        Ensure = 'Present'
        Name = 'Web-Server'
    }
    $dependsOnIIS = '[WindowsFeature]IIS'
    
    WindowsFeature IISMgmt
    {
        Ensure = 'Present'
        Name = 'Web-Mgmt-Tools'
    }
    
    foreach ($webSite in $ConfigData.Roles.WebServer.WebSites.GetEnumerator())
    {
        xWebAppPool "NewWebAppPool_$($webSite.Key)"
        {
            Name   = $webSite.Key
            Ensure = "Present"
            State  = "Started"
            DependsOn = $dependsOnIIS
        }

        #Create physical path website
        File "NewWebsitePath_$($webSite.Key)"
        {
            DestinationPath = $webSite.Value.PhysicalPathWebSite
            Type = "Directory"
            Ensure = "Present"
            DependsOn = $dependsOnIIS
        }

        #Create physical path web application
        File "NewWebApplicationPath_$($webSite.Key)"
        {
            DestinationPath = $webSite.Value.PhysicalPathWebApplication
            Type = "Directory"
            Ensure = "Present"
            DependsOn = $dependsOnIIS
        }

        #Create physical path virtual directory
        File "NewVirtualDirectoryPath_$($webSite.Key)"
        {
            DestinationPath = $webSite.Value.PhysicalPathVirtualDir
            Type = "Directory"
            Ensure = "Present"
            DependsOn = $dependsOnIIS
        }

        #Create a New Website with Port
        xWebSite "NewWebSite_$($webSite.Key)"
        {
            Name   = $webSite.Key
            Ensure = "Present"
            BindingInfo = MSFT_xWebBindingInformation
            {
                Protocol = "http"
                Port = $webSite.Value.Port
            }

            PhysicalPath = $webSite.Value.PhysicalPathWebSite
            State = "Started"
            DependsOn = @("[xWebAppPool]NewWebAppPool_$($webSite.Key)","[File]NewWebsitePath_$($webSite.Key)")
        }

        #Create a new Web Application
        xWebApplication "NewWebApplication_$($webSite.Key)"
        {
            Name = $webSite.Value.WebApplicationName
            Website = $webSite.Key
            WebAppPool =  $webSite.Key
            PhysicalPath = $webSite.Value.PhysicalPathWebApplication
            Ensure = "Present"
            DependsOn = @("[xWebSite]NewWebSite_$($webSite.Key)","[File]NewWebApplicationPath_$($webSite.Key)")
        }

        #Create a new virtual Directory
        xWebVirtualDirectory "NewVirtualDir_$($webSite.Key)"
        {
            Name = $webSite.Value.WebVirtualDirectoryName
            Website = $webSite.Key
            WebApplication =  $webSite.Value.WebApplicationName
            PhysicalPath = $webSite.Value.PhysicalPathVirtualDir
            Ensure = "Present"
            DependsOn = @("[xWebApplication]NewWebApplication_$($webSite.Key)","[File]NewVirtualDirectoryPath_$($webSite.Key)")
        }

        #Create an empty web.config file
        File "CreateWebConfig_$($webSite.Key)"
        {
            DestinationPath = $webSite.Value.PhysicalPathWebSite + "\web.config"
            Contents = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>
                <configuration>
            </configuration>"
            Ensure = "Present"
            DependsOn = @("[xWebVirtualDirectory]NewVirtualDir_$($webSite.Key)")
        }

        #Add an appSetting key1
        xWebConfigKeyValue "ModifyWebConfig_$($webSite.Key)"
        {
            Ensure = "Present"
            ConfigSection = "AppSettings"
            Key = "key1"
            Value = "value1"
            IsAttribute = $false
            WebsitePath = "IIS:\sites\$($webSite.Key)"
            DependsOn = @("[File]CreateWebConfig_$($webSite.Key)")
        }
    }
}