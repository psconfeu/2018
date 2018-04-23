Describe "Prerequists for using ovfDemo"{
    BeforeAll{
        $mandatoryModules = Import-module Pester,ImportExcel,ActiveDirectory,DFSN -PassThru
    }

    Context "Verifying mandatory modules "{
        $mandatoryModules |
        ForEach-Object{
            It "$($_.Name) module should be present" {
                $_.Path | Should -Exist
            }
        }
    }
}
