<#

        Author: I.C.A. Strachan
        Version:
        Version History:

        Purpose: Infrastructure Dependencies script to create AzureADUser from XML file

#>

[CmdletBinding(SupportsShouldProcess=$True)]

Param(
    [string]
    $xmlFileName = 'PSConfEU2018.xml',

    [string]
    $xmlFilePath = 'source\xml'
)

#Get XML File
$xmlFile = $(Join-Path -Path "$PSScriptRoot\$xmlFilePath" -ChildPath $xmlFileName)

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

Function Test-NewADUserParameters{
    param(
        $objActual,
        $objExpected
    )

   
    $allValid = $objActual |
    ForEach-Object{
        @{
            Actual   = $($_)
            Valid    = $($objExpected.Name -contains $_)
        }
    }

    $allValid.Valid -notcontains $False
}

#region Arrange
#Define proper dependencies
#1) Verify xml file exist
#   a) Verify Mandatory Name parameter
#   b) Verify Valid parameters
#2) Verify user can read AzureAD properties.


$dependencies = @(
    @{
        Label  = 'AzureADPreview module is available '
        Test   = {(Get-module -ListAvailable).Name -contains 'AzureADPreview'}
        Action = {
            #Import AzureADPreview
            $null = Import-Module -Name AzureADPreview -Verbose:$false

            #Get New-AzureADUser Parameters available
            $script:parametersNewAzureADUser = (Get-Command New-AzureADUser -ErrorAction Stop).ParameterSets.Parameters | 
            Where-Object {$_.IsDynamic -eq $true}
        }
    }

    @{
        Label  = "XML File at $($xmlFile) exists"
        Test   = {Test-Path -Path $xmlFile}
        Action = {
            $script:xmlPSConfEU       = Import-Clixml -Path $xmlFile 
            $script:xmlPSConfEUColumns = ($xmlPSConfEU | Get-Member -MemberType NoteProperty).Name
            #Removing PasswordProfile from the equation as we can't verify this in hindsight
            $script:UserProperties   = $xmlPSConfEUColumns.Where{$_ -ne 'PasswordProfile'}
        }
    }

    @{
        Label  = "XML contains Mandatory `'AccountEnabled`' parameter"
        Test   = {$script:xmlPSConfEUColumns -Contains 'AccountEnabled' }
        Action = {}
    }

    @{
        Label  = "XML contains Mandatory `'DisplayName`' parameter"
        Test   = {$script:xmlPSConfEUColumns -Contains 'DisplayName' }
        Action = {}
    }

    @{
        Label  = "XML contains Mandatory `'PasswordProfile`' parameter"
        Test   = {$script:xmlPSConfEUColumns -Contains 'PasswordProfile' }
        Action = {}
    }

    @{
        Label  = "XML contains Mandatory `'MailNickName`' parameter"
        Test   = {$script:xmlPSConfEUColumns -Contains 'MailNickName' }
        Action = {}
    }

    @{
        Label  = "XML contains valid parameters For cmdlet New-AzureADUser"
        Test   = {Test-NewADUserParameters -objActual $script:xmlPSConfEUColumns -objExpected $parametersNewAzureADUser}
        Action = {}
    }

    @{
        Label  = "Current user can read AzureAD user object properties"
        Test   = {[bool](Get-AzureADUser -ObjectId 632401f7-dfc9-42f8-948f-e149caa069e4)}
        Action = {}
    }
)

foreach($dependency in $dependencies){
    if(!( & $dependency.Test)){
        throw "The check: $($dependency.Label) failed. Halting script"
    }
    else{
        Write-Host $($dependency.Label) -ForegroundColor Magenta
        $dependency.Action.Invoke()
    }
}
#endregion

#region Main
$xmlPSConfEU[3..6] |
Foreach-Object{

    Describe "Processing User $($Expected.DisplayName)"{

        #region Assert
        #1) Verify AD user has been created correctly
        $Expected = $_

        Context "Creating AzureAD User account for $($Expected.DisplayName) "{
            #Convert to HashTable for splatting
            $paramNewAzureADUser = ConvertTo-HashTable -PSObject $Expected

            #region Act
            #1) Create AZure ADUser from xml file

            It "Created an account for $($Expected.DisplayName)"{
                New-AzureADUser @paramNewAzureADUser
            }
            #endregion
        }

        Context "Verifying AD User properties for $($Expected.DisplayName)"{

            #Get AzureAD user properties
            $Actual = Get-AzureADUser -ObjectId $Expected.UserPrincipalName

            foreach($parameter in $UserProperties){
                It "Verified property $Parameter is set to $($Expected.$parameter) " {
   
                    $Actual.$parameter | should be $Expected.$parameter
                }
            }
            #endregion
        }
    }
}
#endregion