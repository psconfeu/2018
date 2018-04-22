InModuleScope -ModuleName $ModuleName -ScriptBlock {
    Describe "Tests for the Get-SpeakerBeard Command" -Tags Beard , Unit {
        It "Command Get-SpeakerBeard exists" {
            Get-Command Get-SpeakerBeard -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
        }
        Context "Get-SpeakerBeard Input" {
            BeforeAll {
                $MockFace = (Get-Content $Env:ModuleBase\tests\faces.JSON) -join "`n" | ConvertFrom-Json
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
        Context "Get-SpeakerBeard Execution" {
            ## Ensuring the code follows the expected path
            BeforeAll {
                $MockFace = (Get-Content $Env:ModuleBase\tests\faces.JSON) -join "`n" | ConvertFrom-Json
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
        Context "Get-SpeakerBeard Output" {
            ## Probably most of tests here
            BeforeAll {
                $MockFace = (Get-Content $Env:ModuleBase\tests\faces.JSON) -join "`n" | ConvertFrom-Json
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
    }
}