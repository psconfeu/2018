
Describe "Network Settings" {
    It "Should have correct adapter" {
        (Get-NetAdapter -ErrorAction SilentlyContinue ).Name -contains 'Wifi' | Should Be $true
    }
    It "Should have the correct address" {
        ((Get-NetIPAddress -InterfaceAlias 'WiFi'  -ErrorAction SilentlyContinue) | Where {$_.AddressFamily -eq 'Ipv4'}).Ipaddress | Should be '172.16.1.105'
    }
    It "Should have the correct DNS Server" {
      (Get-DnsClientServerAddress -InterfaceAlias 'WiFi' -AddressFamily IPv4).ServerAddresses | Should Be @('172.16.1.1')
    }
}

Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Shoudl have Code Insiders Open" {
            (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not Be 0
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }

        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Continuous Delivery For Modules To PowerShell Gallery.pptx - PowerPoint'
        }
        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should BE 0
        }
        It "Prompt should be Presentations" {
            (Get-Location).Path | Should Be 'Presentations:\PSConfEU2018-ContinuousDelivery'
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
        It "Should have the VSTS Agent Service Running"{
            (Get-Service vstsagent.sewells-consulting.ROB-XPS).Status | Should Be 'Running'
        }
    }
    $ModuleName = [regex]::matches((Get-Content .\Demo.ps1), "\`$ModuleName\s=\s'([\w-]*)'").groups[1].value
    [version]$ManifestVersion = [regex]::matches((Get-Content .\BeardAnalysis.psd1), "\s*ModuleVersion\s=\s'(\d*.\d*.\d*)'\s*").groups[1].value
    [version]$PlasterVersion = [regex]::matches((Get-Content .\Demo.ps1), "\s*Version\s=\s'(\d*.\d*.\d*)'\s*").groups[1].value
    $Gallery = Invoke-WebRequest  https://www.powershellgallery.com/packages/beardanalysis/  -DisableKeepAlive -UseBasicParsing
    [version]$GalleryVersion = [regex]::matches($Gallery.Content,"\s*\|\sBeardAnalysis\s(\d*.\d*.\d*)<").groups[1].value
    Context "Setup" {
        It "PlasterTemplate folder should exist" {
            Test-Path Git:\PlasterTemplate
        }
        It "Module Folder should not exist" {
            Test-Path GIT:\$ModuleName | Should Be $False
        }
        It "Module Version in manifest file should be equal to Gallery Version" {
            $ManifestVersion | Should Be $GalleryVersion 
        }
        It "Module version in manifest file should match Plaster parameter" {
            $ManifestVersion | Should BeExactly $PlasterVersion
        }
        It "GitHub Repo $ModuleName should not exist" {
            Remove-Variable Result -ErrorAction SilentlyContinue
            $Url = 'http://github.com/SQLDBAWithABeard/' + $ModuleName
            try {
                $result = Invoke-WebRequest -Uri $URL -DisableKeepAlive -UseBasicParsing  -Method Head -ErrorAction SilentlyContinue
            }
            catch [System.Net.WebException] {
                Switch ($_.Exception.Message) {
                    'The remote server returned an error: (404) Not Found.' {
                        $result = "Github repo does not exist"
                    }
                    default{
                        $result = "Github repo does not exist"
                    }
                }
            }
            $result| Should BeExactly "Github repo does not exist"
        }
        It "http://tugait.pt/2017/speakers/ should exist and be contactable" {
            Remove-Variable Result -ErrorAction SilentlyContinue
            $Url = 'http://tugait.pt/2017/speakers/'
            try {
                $result = Invoke-WebRequest -Uri $URL -DisableKeepAlive -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
            }
            catch [System.Net.WebException] {
                Switch ($_.Exception.Message) {
                    'The remote server returned an error: (404) Not Found.' {
                        $result = "URL does not exist 404"
                    }
                    default{
                        $result = "An error occured"
                    }
                }
            }
            $result.StatusCode | Should BeExactly 200
        }
        It "should have the correct API Key for faces"{
            $Env:MS_Faces_Key.Substring($Env:MS_Faces_Key.Length -5) | Should Be '48ea9'
        }
        It "Should Not have the Beard Analysis module loaded" {
            Get-Module BeardAnalysis | Should BeNullOrEmpty 
        }
        It "Should Not have the Get-SpeakerBeard command loaded" {
            Get-Command Get-SpeakerBeard -ErrorAction SilentlyContinue | should BeNullOrEmpty
        }
        It "OneDrive should not be running as it interferes with git" {
            Get-Process OneDrive -ErrorAction SilentlyContinue | Should BeNullOrEmpty
        }
    }
}

