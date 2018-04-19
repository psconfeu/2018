function InPesterScope ($ScriptBlock) {
    # like in ModuleScope
    $module = Get-Module Pester
    $data = & $module $ScriptBlock

    $data | Out-String | Write-Host
}

# generate parameters for mock bootstrap function
$command = Get-Command Get-Date
$metadata = [Management.Automation.CommandMetaData]$command
$paramBlock = [Management.Automation.ProxyCommand]::GetParamBlock($metadata)
$paramBlock


# look at the real bootstrap function
describe "d" { 
    it "i" {
        Mock Get-Date { }
        $body = (Get-Alias Get-Date).ResolvedCommand.Definition
        Write-Host $body
    }
}

# look at the real history of mock calls
describe "d" { 
    Mock Get-Date { }
    Get-Date 
    it "i" {
        Mock Get-Date -ParameterFilter { 1998 -eq $year }

        Get-Date 
        Get-Date -Year 2017
        Get-Date -Year 1998
        
        InPesterScope { 
            $command = Get-Command Get-Date
            $mockTable[
                $command.ModuleName + "||" + $command.Name].CallHistory
        }
    }
}


