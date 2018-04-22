$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1

#-------------------------------------------------------------------------------------------------

Invoke-LabCommand -ComputerName $pullServers -ActivityName 'Increasing HTTP buffers' -ScriptBlock {
    $path = 'C:\inetpub\PSDSCPullServer\web.config'
 
    $doc = [xml](Get-Content -Path $path)
    $serviceModelNode = ($doc | Select-Xml -XPath '//system.serviceModel').Node
 
    $bindingsNode = ($doc | Select-Xml -XPath '//system.serviceModel/bindings').Node
    if (-not $bindingsNode)
    {
        $bindingsNode = $doc.CreateElement('bindings')
        [void]$serviceModelNode.AppendChild($bindingsNode)
    }
 
    $webHttpBindingNode = ($doc | Select-Xml -XPath '//system.serviceModel/bindings/webHttpBinding').Node
    if (-not $webHttpBindingNode)
    {
        $webHttpBindingNode = $doc.CreateElement('webHttpBinding')
        [void]$bindingsNode.AppendChild($webHttpBindingNode)
    }
 
    $bindingNode = ($doc | Select-Xml -XPath '//system.serviceModel/bindings/webHttpBinding/binding').Node
    if (-not $bindingNode)
    {
        $bindingNode = $doc.CreateElement('binding')
        [void]$webHttpBindingNode.AppendChild($bindingNode)
    }
 
    $bindingNode.SetAttribute('maxBufferPoolSize', [int]::MaxValue)
    $bindingNode.SetAttribute('maxReceivedMessageSize', [int]::MaxValue)
    $bindingNode.SetAttribute('maxBufferSize', [int]::MaxValue)
    $bindingNode.SetAttribute('transferMode', 'Streamed')
 
    $doc.Save($path)
}

Invoke-LabCommand -ActivityName 'Create a restricted endpoint for registering DSC nodes' -ComputerName $pullServers -ScriptBlock {
    Register-SupportPSSessionConfiguration -UseVirtualAccount -AllowedPrincipals "$($env:USERDOMAIN)\Domain Computers"
}

Invoke-LabCommand -ActivityName 'Add ODBC System DSN' -ComputerName $pullServers -ScriptBlock {
    Add-OdbcDsn -Name DSC -DriverName 'SQL Server' -Platform '32-bit' -DsnType System -SetPropertyValue @('Description=DSC Pull Server', "Server=$($sqlServer.Name)", 'Trusted_Connection=yes', 'Database=DSC')
} -Variable (Get-Variable -Name sqlServer)

Copy-LabFileItem -Path "$PSScriptRoot\Devices.mdb" -ComputerName $pullServers -DestinationFolder 'C:\Program Files\WindowsPowerShell\DscService'