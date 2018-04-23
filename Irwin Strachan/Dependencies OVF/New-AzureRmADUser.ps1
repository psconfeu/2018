#region Connect to AzureAD
try{
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary -ErrorAction Stop
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client    

    $AzureCred = Import-Clixml -Path "${env:\userprofile}\AzureIrwin.Cred"  
    $paramConnectAzureAD = @{
        TenantID = $AzureCred.AzureIrwin.TenantID
    }
    Connect-AzureAD @paramConnectAzureAD -ErrorAction Stop
}
catch {
    # get error record
    [Management.Automation.ErrorRecord]$e = $_

    # retrieve information about runtime error
    $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
    }
    
    # output information. Post-process collected info, and log info (optional)
    $info
}
#endregion 

#region Get Parameters for New-AzureADUser
$paramsNewAzureADUser = (Get-Command New-AzureADUser -ErrorAction Stop).ParameterSets.Parameters | 
Where-Object {$_.IsDynamic -eq $true}
Clear-Host
'Total parameters New-AzureADUser cmdlet: {0}' -f $paramsNewAzureADUser.Count



#Mandatory parameters New-AzureADUser
$paramsNewAzureADUserMandatory = $paramsNewAzureADUser.Where{$_.IsMandatory -eq $true} |
Select-Object -ExpandProperty Name
Clear-Host
'Mandatory New-AZureADUSer parameters: {0}' -f $($paramsNewAzureADUserMandatory -join ', ')
#endregion

#region Import CSV file
$csvDemoUsers = Import-csv $PSScriptRoot\source\csv\PSConfEU.csv -Delimiter "`t" -Encoding UTF8 
$csvDemoUsersHeaders = ($csvDemoUsers | Get-Member -MemberType NoteProperty).Name
Clear-host
Write-host 'CSV Headers' -ForegroundColor Magenta
$csvDemoUsersHeaders
#endregion

#region Check if CSV has valid Headers
Function Test-CSVNewAzureADUserParameters{
    param(
        $csvHeader,
        $paramCmdlet
    )

    $csvHeader |
    ForEach-Object{
        [PSCustomObject]@{
            Header   = $($_)
            Valid    = $($paramCmdlet -contains $_)
        }
    }
}

$TestCSVHeaders = Test-CSVNewAzureADUserParameters -csvHeader $csvDemoUsersHeaders -paramCmdlet $paramsNewAzureADUser.Name
$valid   = $TestCSVHeaders.Where{$_.valid -eq $true} | Select-Object -ExpandProperty Header
Clear-host
Write-Host 'Valid CSV headers for New-AzureADUser' -ForegroundColor Magenta
$valid
$invalid = $TestCSVHeaders.Where{$_.valid -eq $false} | Select-Object -ExpandProperty Header
Clear-host
Write-Host 'Invalid CSV headers for New-AzureADUser' -ForegroundColor Magenta
$invalid
#endregion

#region Add PasswordProfile,AccountEnabled and MailNickName to 
$newDemoUsers = $csvDemoUsers |
ForEach-Object{
    $obj = @{}
    $item = $_ 

    $item |
    Get-Member -MemberType *Property |
    ForEach-Object{
        if( $Valid.Contains($_.Name)){
            $obj.$($_.Name) = $item.$($_.Name)
        }
    }
    
    #Create PasswordProfile object
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $_.Password
    $PasswordProfile.EnforceChangePasswordPolicy = $true
    $PasswordProfile.ForceChangePasswordNextLogin = $true

    #Add Passwordprofile to hash
    $obj.PasswordProfile =  $PasswordProfile
    $obj.AccountEnabled = $true
    #It seems that MailNickName is also Mandatory
    $obj.MailNickName = ($obj.UserPrincipalName -split '@')[0]
    [PSCustomObject]$obj
}

#region Save as XML file
$newDemoUsers | Export-Clixml -Path $PSScriptRoot\source\xml\PSConfEU2018.xml -Encoding UTF8
#endregion

#Test Valid Headers again
$DemoUsersHeaders = ($newDemoUsers | Get-Member -MemberType NoteProperty).Name
$TestCSVHeaders = Test-CSVNewAzureADUserParameters -csvHeader $DemoUsersHeaders -paramCmdlet $paramsNewAzureADUser.Name
Clear-host
Write-Host 'Valid CSV headers for New-AzureADUser' -ForegroundColor Magenta
$valid   = $TestCSVHeaders.Where{$_.valid -eq $true} | Select-Object -ExpandProperty Header
$valid

Clear-host
Write-Host 'Invalid CSV headers for New-AzureADUser' -ForegroundColor Magenta
$invalid = $TestCSVHeaders.Where{$_.valid -eq $false} | Select-Object -ExpandProperty Header
$invalid
#endregion

#region Create New AzureAD User
function ConvertTo-HashTable{
    param(
        [PSObject]$PSObject
    )
    $splat = @{}

    $PSObject | 
    Get-Member -MemberType *Property |
    ForEach-Object{
         $splat.$($_.Name) = $PSObject.$($_.Name)
    }

    $splat
}

$newAzureAdUser = ConvertTo-HashTable -PSObject $newDemoUsers[2]

try{
    New-AzureADUser @newAzureAdUser
}
catch [Microsoft.Open.AzureAD16.Client.ApiException]{
    $WarningMessage = '{0} {1}' -f ($Error[0].Exception.Message -split "`n")[2], $newAzureAdUser.UserPrincipalName
    Write-Warning -Message $WarningMessage
}
catch{
    Write-Warning "Something went wrong"
}
#endregion

