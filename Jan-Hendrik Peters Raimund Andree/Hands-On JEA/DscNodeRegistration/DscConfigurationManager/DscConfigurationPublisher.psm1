function Get-DscConfigurationImportedResource
{
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByFile')]
        [string]$FilePath,
        
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name
    )
    
    $modules = New-Object System.Collections.ArrayList

    if ($Name)
    {
        $ast = (Get-Command -Name $Name).ScriptBlock.Ast
        $FilePath = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ScriptBlockAst] }, $true)[0].Extent.File
    }
    
    $ast = [scriptblock]::Create((Get-Content -Path $FilePath -Raw)).Ast
    
    $configurations = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ConfigurationDefinitionAst] }, $true)
    Write-Verbose "Script knwos about $($configurations.Count) configurations"
    foreach ($configuration in $configurations)
    {
        $importCmds = $configuration.Body.ScriptBlock.FindAll({ $args[0].Value -eq 'Import-DscResource' -and $args[0] -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true)
        Write-Verbose "Configuration $($configuration.InstanceName) knows about $($importCmds.Count) Import-DscResource commands"
    
        foreach ($importCmd in $importCmds)
        {
            $commandElements = $importCmd.Parent.CommandElements | Select-Object -Skip 1 | Where-Object {$_ -is [System.Management.Automation.Language.ArrayLiteralAst] -or $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] }     
            
            $moduleNames = $commandElements.SafeGetValue()
            if ($moduleNames.GetType().IsArray)
            {
                $modules.AddRange($moduleNames)
            }
            else
            {
                [void]$modules.Add($moduleNames)
            }
        }
    }
    
    $compositeResources = $modules | Where-Object { $_ -ne 'PSDesiredStateConfiguration' } | ForEach-Object { Get-DscResource -Module $_ } | Where-Object { $_.ImplementedAs -eq 'Composite' }
    foreach ($compositeResource in $compositeResources)
    {
        $modulesInResource = Get-DscConfigurationImportedResource -FilePath $compositeResource.Path
        if ($modulesInResource.GetType().IsArray)
        {
            $modules.AddRange($modulesInResource)
        }
        else
        {
            [void]$modules.Add($modulesInResource)
        }
    }
    
    $modules | Select-Object -Unique
}

function Publish-DscBuilderConfiguration
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string[]]$ComputerName,
       
        [Parameter(Mandatory, ParameterSetName = 'ConfigurationName')]
        [string[]]$ConfigurationName,
        
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$All,
        
        [Parameter(Mandatory)]
        [hashtable]$ConfigurationData,
        
        [string]$OutputPath = $MyInvocation.MyCommand.Module.PrivateData.MofFileLocation
    )
    
    if(-not (Test-path -Path $OutputPath))
    {
        mkdir -Path $OutputPath | Out-Null
    }

    $dscModules = @()

    if ($PSCmdlet.ShouldProcess($ComputerName, "Create new DSC MOFs for computer type '$ComputerName'"))
    {
        Remove-Item -Path C:\$OutputPath\* -ErrorAction SilentlyContinue
        
        $functions = Get-DscBuilderConfiguration
        
        foreach ($function in $functions)
        {
            if ($function.Parameters.ComputerName)
            {
                &$function -ComputerName $ComputerName -ConfigurationData $ConfigurationData -OutputPath $OutputPath
            }
            else
            {
                &$function -ConfigurationData $ConfigurationData -OutputPath $OutputPath
            }

            $dscModules += Get-DscBuilderResourceFromConfiguration -ScriptBlock $function.ScriptBlock
        }

        $dscModules = $dscModules | Select-Object -Unique
        Publish-DSCModuleAndMof -Source $OutputPath -ModuleNameList $dscModules -Force
    }
    
    $pullServerConfigs = Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\DscService\Configuration'
    Write-Information -MessageData "Configuration folder knows about $($pullServerConfigs.Count) MOF files" -Tags DSC
}

function Publish-DscConfiguration
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ConfigurationInfo]$Configuration,

        [Parameter(Mandatory)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory)]
        [hashtable]$ConfigurationData,
        
        [string]$OutputPath = $MyInvocation.MyCommand.Module.PrivateData.MofFileLocation
    )

    $tempPath = [System.IO.Path]::GetTempFileName()
    Remove-Item -Path $tempPath
    mkdir -Path $tempPath | Out-Null
    
    if(-not (Test-path -Path $OutputPath))
    {
        mkdir -Path $OutputPath | Out-Null
    }
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    Remove-Item -Path $tempFile
    $tempFile = [System.IO.Path]::ChangeExtension($tempFile, '.ps1')
    
    $Configuration.ScriptBlock.Ast.Parent.ToString() | Out-File -FilePath $tempFile

    . $tempFile

    $dscModules = @()

    if ($PSCmdlet.ShouldProcess($ComputerName, "Create new DSC MOFs for computer type '$ComputerName'"))
    {
        $null = foreach ($c in $ComputerName)
        {
            $adaptedConfig = $ConfigurationData.Clone()

            Write-Information -MessageData "Creating Configuration MOF '$($Configuration.Name)' for node '$c'" -Tags DSC
            $configAvailable = [bool](Get-Command -Name $Configuration.Name -CommandType Configuration)
            Write-Information -MessageData "Configuration '$($Configuration.Name)' found using Get-Command: $configAvailable" -Tags DSC
            
            Write-Information "Invoking configuration '$($Configuration.Name)' with output path '$tempPath' and ComputerName '$c'"
            $mof = & $Configuration.Name -OutputPath $tempPath -ConfigurationData $adaptedConfig -ComputerName $c
            $mof = $mof | Rename-Item -NewName "$($Configuration.Name)_$c.mof" -Force -PassThru
            $mof | Move-Item -Destination $OutputPath -Force
            
            Remove-Item -Path $tempPath -Force
        }

        #Get-DscConfigurationImportedResource now needs to walk over all the resources used in the composite resource
        #to find out all the reuqired modules we need to upload in total
        Write-Information "Calling 'Get-DscConfigurationImportedResource'"
        $dscModules = Get-DscConfigurationImportedResource -FilePath $tempFile
    }
    
    Remove-Item -Path $tempFile
    
    Write-Information "Calling 'Publish-DSCModuleAndMof'"
    Publish-DSCModuleAndMof -Source $OutputPath -ModuleNameList $dscModules -Force | Out-Null
    
    $pullServerConfigs = Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\DscService\Configuration'
    Write-Information -MessageData "Configuration folder knows about $($pullServerConfigs.Count) MOF files" -Tags DSC
}