## load the function
. .\functions\Get-SpeakerBeard.ps1
$CommandName = 'Get-SpeakerBeard'

Describe "Tests for the $CommandName Command" {

    It "Command $CommandName exists" {
        (Get-Command $CommandName -ErrorAction SilentlyContinue).Name | Should BE $CommandName
    }

    Context "$CommandName Input" {
        BeforeAll {
            $MockFace = (Get-Content $presentation\faces.JSON) -join "`n" | ConvertFrom-Json
            Mock Get-SpeakerFace {$MockFace}
        }
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

    }
    Context "$CommandName Output" {
        ## Probably most of tests here
    }
    
}