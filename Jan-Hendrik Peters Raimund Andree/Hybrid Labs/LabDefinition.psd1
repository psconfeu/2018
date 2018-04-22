@(
    @{
        LabName = 'pshsrc'
        AddressSpace = '192.168.50.0/24'
        Domain = 'powershell.isawesome'
        Dns1 = '192.168.50.10'
        Dns2 ='192.168.50.11'
        OnAzure = $false
        Location = 'West Europe'
    }
    @{
        LabName = 'jhppshds'
        AddressSpace = '192.168.100.0/24'
        Domain = 'powershell.power'
        Dns1 = '192.168.100.10'
        Dns2 ='192.168.100.11'
        Location = 'West Europe'
        OnAzure = $true
    }
    @{
        LabName = 'jhppshds2'
        AddressSpace = '192.168.150.0/24'
        Domain = 'powershell.power'
        Dns1 = '192.168.150.10'
        Dns2 ='192.168.150.11'
        Location = 'West Europe'
        OnAzure = $true
    }
)