function Convert-CsvToHashTable
{
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [char]
        $Delimiter = ','
    )
    
    if (-not (Test-Path -Path $Path -PathType Leaf))
    {
        Write-Error "The file '$Path' could not be found"
        return
    }
    
    $data = Import-Csv -Path $Path -Delimiter $Delimiter -ErrorAction Stop
    Write-Verbose "Imported $($data.Count) entries"
    $props = $data | Get-Member -MemberType NoteProperty
    Write-Verbose "The entries have $($props.Count) properties"

    foreach ($item in $data)
    {
        $h = @{}
        foreach ($prop in $props)
        {
            $propName = $prop.Name
            $h."$propName" = $item."$propName"
        }
        $h
    }
}

function Import-DscConfigurationData
{
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$GlobalConfigurationFileName
    )

    $InformationPreference = 'Continue'

    $globalConfigurationPath = Join-Path -Path $Path -ChildPath $GlobalConfigurationFileName
    if (-not (Test-Path -Path $globalConfigurationPath -PathType Leaf))
    {
        Write-Error "The GlobalConfigurationFileName '$($globalConfigurationPath)' could not be found."
        return
    }
    
    if ([System.IO.Path]::GetExtension($globalConfigurationPath) -ne '.psd1')
    {
        Write-Error "The GlobalConfigurationFile has the wrong extention. It must be a .psd1 file."
        return
    }
    
    $config = Import-DscConfigurationDataInternal -FilePath "$Path\GlobalConfigurationData.psd1"
    $config | Add-DscConfigurationDataItem -Path "$Path\Nodes.csv" -HashtablePath 'AllNodes' -AsHashTable
    
    $files = Get-ChildItem -Path $Path | Where-Object Name -Match '(\w+)(_(\w+))(.txt|.csv|.psd1)'
    foreach ($file in $files)
    {
        Write-Host "Adding file '$file' to configuration data"
        $hashtablePath = $file.BaseName -split '_'
        $config | Add-DscConfigurationDataItem -Path $file.FullName -HashtablePath $hashtablePath
    }
    
    $config
}

function Import-DscConfigurationDataInternal
{
    param(
        #[Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [Parameter(Mandatory)]
        [string]$FilePath
        
        #[hashtable[]]$NodeData
    )

    if (-not (Test-Path -Path $FilePath))
    {
        Write-Error "The path '$FilePath' does not exist"
        return
    }

    $config = @{}
    $parentPath = Split-Path -Path $FilePath -Parent
    $fileName = Split-Path -Path $FilePath -Leaf

    Import-LocalizedData -BaseDirectory $parentPath -FileName $fileName -BindingVariable config -SupportedCommand New-Object, ConvertTo-SecureString
    
    #$config.AllNodes += $nodeData
    $config
}

function Add-DscConfigurationDataItem
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable]
        $ConfigurationData,

        [char]
        $Delimiter = ',',

        [string[]]$HashtablePath,
        
        [switch]$AsHashTable,
        
        [switch]$PassThru
    )

    process
    {
        if (-not (Test-Path $Path))
        {
            Write-Error "Could not find $Path. No data item will be added to the configuration."
            return
        }
    
        $tempTable = $ConfigurationData
        $upperBound = [int](($HashtablePath.Count - 1) -as [uint32])
    
        foreach ($element in ($HashtablePath | Select-Object -First $upperBound))
        {
            if (-not $tempTable.ContainsKey($element))
            {
                $tempTable.Add($element, @{})
            }
            $tempTable = $tempTable[$element]
        }
    
        $content = switch ([System.IO.Path]::GetExtension($Path))
        {
            '.csv' {
                if ($AsHashTable)
                {
                    Convert-CsvToHashTable -Path $Path -Delimiter $Delimiter
                }
                else
                {
                    Import-Csv -Path $Path -Delimiter $Delimiter
                }
            
            }
            '.txt' {
                Get-Content -Path $Path | Where-Object { $_ -notlike '#*' }
            }
            '.psd1' { 
                Import-DscConfigurationDataInternal -FilePath $Path
            }
        }
    
        if (-not $tempTable."$($HashtablePath[-1])")
        {
            $tempTable."$($HashtablePath[-1])" = @{}
        }
        if ($tempTable."$($HashtablePath[-1])".GetType().IsArray)
        {
            $tempTable."$($HashtablePath[-1])" += $content
        }
        else
        {
            $tempTable."$($HashtablePath[-1])" = $content
        }
 
        if ($PassThru)
        {
            $ConfigurationData
        }
    }
}