## load the function
. .\functions\Get-SpeakerBeard.ps1
## Only becuase I have the demo in a different place to the module
## normally use
<#
 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 #>

$here = 'functions'
$Sut = 'Get-SpeakerBeard.ps1'
$CommandName = 'Get-SpeakerBeard'

Describe "Tests for the $CommandName Command" {
    It "Command $CommandName exists" {
        Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
    }
    Context "$CommandName Input" {
        BeforeAll {
            $MockFace = (Get-Content $presentation\faces.JSON) -join "`n" | ConvertFrom-Json
            Mock Get-SpeakerFace {$MockFace}
        }
        ## For Checking parameters
        It 'When there is no speaker in the array should return a useful message' {
            Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
        }
        It 'Checks the Mock was called for Speaker Face' {
            $assertMockParams = @{
                'CommandName' = 'Get-SpeakerFace'
                'Times'       = 1
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams 
        }
    
    }
    Context "$CommandName Execution" {
        ## Ensuring the code follows the expected path
        BeforeAll {
            $MockFace = (Get-Content $presentation\faces.JSON) -join "`n" | ConvertFrom-Json
            Mock Get-SpeakerFace {$MockFace}
            Mock Start-Process {}
        }
        It 'Opens the image if ShowImage switch used' {
            Get-SpeakerBeard -Speaker Jaap -ShowImage | Should Be 0.2
        }
        It "Opens the image if ShowImage switch used and Detailed Switch" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed -ShowImage)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
        }
        It 'Checks the Mock was called for Speaker Face' {
            $assertMockParams = @{
                'CommandName' = 'Get-SpeakerFace'
                'Times'       = 2
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams 
        }
        It 'Checks the Mock was called for Start-Process' {
            $assertMockParams = @{
                'CommandName' = 'Start-Process'
                'Times'       = 2
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams 
        }
    }
    Context "$CommandName Output" {
        ## Probably most of tests here
        BeforeAll {
            $MockFace = (Get-Content $presentation\faces.JSON) -join "`n" | ConvertFrom-Json
            Mock Get-SpeakerFace {$MockFace}
        }
        It "Should Return the Beard Value for a Speaker" {
            Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
        }
        It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
        }
        It 'Checks the Mock was called for Speaker Face' {
            $assertMockParams = @{
                'CommandName' = 'Get-SpeakerFace'
                'Times'       = 2
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams 
        }
        It "Returns the Top 1 Ranked Beards" {
            (Get-SpeakerBeard -Top 1).beard.Count | Should Be 1
        }
        It "Returns the Bottom  1 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 1).beard.Count | Should Be 1
        }
        It "Returns the Top 5 Ranked Beards" {
            (Get-SpeakerBeard -Top 5).beard.Count | Should Be 5
        }
        It "Returns the Bottom  5 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 5).beard.Count | Should Be 5
        }
    }
   
   
    ## Add Script Analyser Rules
    Context "Testing $commandName for Script Analyser" {
        $Rules = Get-ScriptAnalyzerRule 
        $Name = $sut.Split('.')[0]
        foreach ($rule in $rules) { 
            $i = $rules.IndexOf($rule)
            It "passes the PSScriptAnalyzer Rule number $i - $rule  " {
                (Invoke-ScriptAnalyzer -Path "$here\$sut" -IncludeRule $rule.RuleName ).Count | Should Be 0 
            }
        }
    }
   
    ##            	
    ## 	.NOTES
    ## 		===========================================================================
    ## 		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.119
    ## 		Created on:   	4/12/2016 1:11 PM
    ## 		Created by:   	June Blender
    ## 		Organization: 	SAPIEN Technologies, Inc
    ## 		Filename:		*.Help.Tests.ps1
    ## 		===========================================================================
    ## 	.DESCRIPTION
    ## 	To test help for the commands in a module, place this file in the module folder.
    ## 	To test any module from any path, use https://github.com/juneb/PesterTDD/Module.Help.Tests.ps1
    ## 
    ##     ## ALTERED FOR ONE COMMAND - Rob Sewell 10/05/2017
    ## 
    Describe "Test help for $commandName" {
        # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
        $Help = Get-Help $commandName -ErrorAction SilentlyContinue
        # If help is not found, synopsis in auto-generated help is the syntax diagram
        It "should not be auto-generated" {
            $Help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
        }
           
        # Should be a description for every function
        It "gets description for $commandName" {
            $Help.Description | Should Not BeNullOrEmpty
        }
           
        # Should be at least one example
        It "gets example code from $commandName" {
            ($Help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
        }
           
        # Should be at least one example description
        It "gets example help from $commandName" {
            ($Help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
        }
           
        Context "Test parameter help for $commandName" {
            $command = Get-Command $CommandName
            $Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable',
            'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable'
               
            $parameters = $command.ParameterSets.Parameters | Sort-Object -Property Name -Unique | Where-Object Name -notin $common
            $parameterNames = $parameters.Name
            $HelpParameterNames = $Help.Parameters.Parameter.Name | Sort-Object -Unique
               
            foreach ($parameter in $parameters) {
                $parameterName = $parameter.Name
                $parameterHelp = $Help.parameters.parameter | Where-Object Name -EQ $parameterName
                   
                # Should be a description for every parameter
                It "gets help for parameter: $parameterName : in $commandName" {
                    $parameterHelp.Description.Text | Should Not BeNullOrEmpty
                }
                   
                # Required value in Help should match IsMandatory property of parameter
                It "help for $parameterName parameter in $commandName has correct Mandatory value" {
                    $codeMandatory = $parameter.IsMandatory.toString()
                    $parameterHelp.Required | Should Be $codeMandatory
                }
                   
                # Parameter type in Help should match code
                It "help for $commandName has correct parameter type for $parameterName" {
                    $codeType = $parameter.ParameterType.Name
                    # To avoid calling Trim method on a null object.
                    $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                    $helpType | Should be $codeType
                }
            }
               
            foreach ($helpParm in $HelpParameterNames) {
                # Shouldn't find extra parameters in help.
                It "finds help parameter in code: $helpParm" {
                    $helpParm -in $parameterNames | Should Be $true
                }
            }
        }
    }
        
}