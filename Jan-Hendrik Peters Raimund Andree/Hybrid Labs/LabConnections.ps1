Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName 'LabDefinition.psd1' -BindingVariable labs
break

#region Creation of lab environment
function Test-LabConnected
{
    Import-Lab $labs[1].LabName -NoValidation    
    
    $result = Invoke-LabCommand POSHDC1 -ScriptBlock {
        param
        (
            $connectedLabMachine
        )
    
        if(Test-Connection $connectedLabMachine -ErrorAction SilentlyContinue)
        {
            "Connection established"
        }
        else
        {
            Write-Warning "Could not connect to $connectedLabMachine"
        }
    } -ArgumentList "POSHDC1.$($labs[0].Domain)" -PassThru
    
    if ($result)
    {
        Send-ALNotification -Activity 'Connection to Azure' -Message 'Connection established' -Provider Ifttt,Toast
        return $true
    }
    else
    {
        Send-ALNotification -Activity 'Connection to Azure' -Message 'Connection failed' -Provider Ifttt,Toast
        return $false
    }
}

$azureRmContext = 'D:\Jhp.azurermsettings' # Hint: Save-AzureRmContext

foreach ($lab in $labs)
{
    $engine = if($lab.OnAzure){"Azure"}else{"HyperV"}
    New-LabDefinition -Name $lab.LabName -DefaultVirtualizationEngine $engine

    if($lab.OnAzure)
    {
        continue
        Add-LabAzureSubscription -Path $azureRmContext -DefaultLocationName $lab.Location
    }

    #make the network definition
    Add-LabVirtualNetworkDefinition -Name $lab.LabName -AddressSpace $lab.AddressSpace
    if (-not $lab.OnAzure)
    {
        Add-LabVirtualNetworkDefinition -Name ExternalDHCP -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }
    }

    #and the domain definition with the domain admin account
    Add-LabDomainDefinition -Name $lab.Domain -AdminUser Install -AdminPassword Somepass1

    Set-LabInstallationCredential -Username Install -Password Somepass1

    #defining default parameter values, as these ones are the same for all the machines
    $PSDefaultParameterValues = @{
        'Add-LabMachineDefinition:Network' = $lab.LabName
        'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
        'Add-LabMachineDefinition:DomainName' = $lab.Domain
        'Add-LabMachineDefinition:DnsServer1' = $lab.Dns1
        'Add-LabMachineDefinition:DnsServer2' = $lab.Dns2
        'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 SERVERDATACENTER'
    }

    #The PostInstallationActivity is just creating some users
    $postInstallActivity = @()
    $postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
    $postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
    Add-LabMachineDefinition -Name POSHDC1 -Memory 512MB -Roles RootDC -IpAddress $lab.Dns1 -PostInstallationActivity $postInstallActivity

    #the root domain gets a second domain controller
    Add-LabMachineDefinition -Name POSHDC2 -Memory 512MB -Roles DC -IpAddress $lab.Dns2

    #file server
    Add-LabMachineDefinition -Name POSHFS1 -Memory 512MB -Roles FileServer

    #web server
    Add-LabMachineDefinition -Name POSHWeb1 -Memory 512MB -Roles WebServer

    #router
    if (-not $lab.OnAzure)
    {
        $netAdapter = @()
        $netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $lab.LabName
        $netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch ExternalDHCP -UseDhcp
        Add-LabMachineDefinition -Name POSHGW1 -Memory 512MB -Roles Routing -NetworkAdapter $netAdapter
    }

    Install-Lab

    Show-LabDeploymentSummary
}

#endregion

#Import-Lab -Name pshsrc -NoValidation
#Checkpoint-LabVm -SnapshotName BeforeConnection
break

#region Creating a new lab connection
# This step can take up to 30 minutes
Connect-Lab -SourceLab $labs[0].LabName -DestinationLab $labs[1].LabName -Verbose

Test-LabConnected
#endregion

break

#region Reconnect lab in case internet connection changes
Restore-LabConnection -SourceLab $labs[0].LabName -DestinationLab $labs[1].LabName -Verbose

Test-LabConnected
#endregion

break

#region Remove the connection
Disconnect-Lab -SourceLab $labs[0].LabName -DestinationLab $labs[1].LabName -Verbose
#endregion