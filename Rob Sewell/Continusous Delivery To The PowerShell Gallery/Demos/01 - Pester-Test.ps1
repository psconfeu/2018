## load the function
. .\functions\Get-SpeakerBeard.ps1
$CommandName = 'Get-SpeakerBeard'

## Describe block - this is Pester specific language
## Curly brace must be on same line
Describe "Tests for the $CommandName Command" {

    ## A test is an It Code Block
    ## It has a name 
    ## Actual Value Pipe Should Assert to expected result

    It "Command $CommandName exists" {
        (Get-Command $CommandName -ErrorAction SilentlyContinue).Name | Should BE $CommandName
    }

    ## A Context allows for scoping and grouping of It blocks (tests)

    Context "$CommandName Input" {
        ## For Checking parameters
        It 'When there is no speaker in the array should return a useful message' {
            Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
        }

    }
    Context "$CommandName Execution" {
        ## Ensuring the code follows the expected path

    }
    Context "$CommandName Output" {
        ## Probably most of tests here
    }
    
}