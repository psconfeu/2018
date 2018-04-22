Return "This is a demo beardy"

## You can find everything here https://github.com/SQLDBAWithABeard/Presentations/tree/master/PSDay%20-%20Intro%20To%20TDD%20with%20Pester
$Presentation = 'Presentations:\PSConfEU2018-ContinuousDelivery'

cd $Presentation
Invoke-Pester .\Pester.Tests.ps1


## Start with a Plaster Module
## This is a template framework to reduce you from creating all the usual scaffolding
## This is mine

## Take a look at the PlasterManifest.xml Thats where the magic happens

cd Git:\PlasterTemplate
code-insiders . 

## You can find mine here https://github.com/SQLDBAWithABeard/PlasterTemplate

## Then create your module

$ModuleName = 'BeardAnalysis'
$Description = "This is a demo module for demoing Plaster and TDD with Pester and CI with VSTS to the PowerShell Gallery"

$plaster = @{
    TemplatePath = "GIT:\PlasterTemplate" #(Split-Path $manifestProperties.Path)
    DestinationPath = "Git:\$ModuleName"
    FullName = "Rob Sewell"
    ModuleName = $ModuleName
    ModuleDesc = $Description
    Version = '0.9.27'
    GitHubUserName = "SQLDBAWithABeard"
    GitHubRepo = $ModuleName
    }
    If(!(Test-Path $plaster.DestinationPath))
    {
    New-Item -ItemType Directory -Path $plaster.DestinationPath
    }
    Invoke-Plaster @plaster -Verbose

    ## lets have a look what has been created

    cd Git:\$ModuleName
    code-insiders . 

    ## Publish to GitHub using this function from Jeff Hicks to create a repo

    . Git:\Functions\New-GitHubRepository.ps1

    $Repo = New-GitHubRepository -Name $ModuleName -Description $Description

    Start-Process $Repo.URL

    git init
    git add *
    git commit -m "Added framework using Plaster Template"
    git remote add origin $Repo.Clone
    ## publish branch
    git push --set-upstream origin master

## Lets write a module to analyse the beards on this page

Start-Process http://tugait.pt/2017/speakers/

## The Get-SpeakerFace function uses the Microsoft Cognative Services Faces API and gets a number of properties for each image

## Run then talk
. 'Presentations:\PSDayUK 2017 - Continuous Delivery to PowerShell Gallery\Get-SpeakerFace.ps1'
Copy-Item -Path $Presentation\Get-SpeakerFace.ps1 -Destination Git:\$ModuleName\functions
git add .\functions\Get-SpeakerFace.ps1
git commit -m "Added Get-SpeakerFace"

$speakerfaces = Get-SpeakerFace 
$speakerfaces

## Lets look at one of those objects

$speakerfaces.Where{$_.Name -eq 'JaapBrasser'} | ConvertTo-Json

## We are going to be using the Speaker page on Tugait
## We will analyse the pictures and see if there are any good beards!!

## First lets create a file

New-Item .\functions\Get-SpeakerBeard.ps1 -ItemType File
git add .\functions\Get-SpeakerBeard.ps1
git commit -m "Added Get-SpeakerBeard"

## when we are doing TDD we write our tests first and then our code to pass the tests

## Our command will have a speaker parameter and it should return 
## some information if there is no speaker

## Lets look in 01 Pester-test.ps1

## We can run it with 

Invoke-Pester "$Presentation\01 - Pester-Test.ps1"

## Ah

## Now we write the code to pass the test

Get-Content "$Presentation\a01 - function.ps1" | Set-Content .\functions\Get-SpeakerBeard.ps1
git add .\functions\Get-SpeakerBeard.ps1
git commit -m "Beard command - Error message if no speaker"

## Now run the test again
## Have a look in a01 function.ps1 whilst it's running

Invoke-Pester "$Presentation\01 - Pester-Test.ps1"

## Spot the flaw ?





## Watch

## Turn Wifi off

Invoke-Pester "$Presentation\01 - Pester-Test.ps1"








## WTH ? We didnt change any code and yet our test has failed

## Write your tests so that all they are testing is the code you are writing
## For Pester we have a Mock command
## We will mock the object returned from our Get-SpeakerBeard command using the faces.json file

## look in 02 - Pester-Test.ps1

Invoke-Pester "$Presentation\02 - Pester-Test.ps1"

## Turn Wifi back on again now :-)

## So we can write good tests to ensure that our code does what we expect
## We can write tests to ensure that it follows good practice using PSScriptAnalyzer
## We can write tests that check that we have good help for our functions as well
## Our Tests will explain what we are doing for the future us when we refactor
## Lets have a look through a full Pester test 
## look in 03 - Pester-Test.ps1

## And run the tests - You would normally build these up in steps but you can see that 
## we have written tests for our code, using mocks so that we don't have any external 
## dependancies and ensuring that we follow the Script Analyzer Rules 
## and have GOOD HELP - more on that later!

Invoke-Pester "$Presentation\03 - Pester-Test.ps1"

## If we have lots of tests it becomes difficult to see what happened
## Maybe we only want to see the ones that fail

Invoke-Pester "$Presentation\03 - Pester-Test.ps1" -Show Failed

## Not as useful. Fails is better as you can see the Describe and Context and Summary as well as the failures
## There are also other options for the show if you require them

Invoke-Pester "$Presentation\03 - Pester-Test.ps1" -Show Fails

## You could show nothing and save the results in an object

$PesterResults = Invoke-Pester "$Presentation\03 - Pester-Test.ps1" -Show None -PassThru
$PesterResults
$PesterResults.TestResult

## Or save them to a file

Invoke-Pester "$Presentation\03 - Pester-Test.ps1" -Show Summary -OutputFile C:\temp\PesterResults.xml -OutputFormat NUnitXml
$psEditor.Workspace.NewFile()
Get-Content C:\temp\PesterResults.xml | Out-CurrentFile

## Lets "write" the code to fix all the tests

Get-Content "$Presentation\a02 - function.ps1" | Set-Content .\functions\Get-SpeakerBeard.ps1
git add .\functions\Get-SpeakerBeard.ps1
# Yes I know!
git commit -m "Beard command - Code, output, functionality, help, PSScriptAnalyzer"

Invoke-Pester "$Presentation\03 - Pester-Test.ps1" 

## Thats only one command
## what about the module you were talking about earlier Beardy ?
## Good point
## Lets copy the tests into the Unit.Tests.ps1 file in the test folder

Get-Content "$Presentation\get-speakerbeard module tests.ps1" | Add-Content Git:\$ModuleName\tests\Unit.Tests.ps1
git add .\tests\Unit.Tests.ps1
git commit -m "Added Get-SpeakerBeard Tests"

## WE are alos going to add the faces.json for mocking in pur Pester tests
Copy-Item $Presentation\faces.json -Destination Git:\$ModuleName\Tests
git add .\tests\faces.json
git commit -m "Added faces json for mocking"

## You can run Pester against a folder and it will run all of the .Tests.ps1 files

## If we were just wanting to run the commands for the Get-SpeakerBeard Command we can use tags
## This would be when we were working locally and developing our command or module

Invoke-Pester .\tests -Show Fails -Tag Beard

## Check that the help is ok

Invoke-Pester .\tests -tag help

## Check our Code is following ScriptAnalyzer Rules

Invoke-Pester .\tests -Show Fails -Tag ScriptAnalyzer

## OK we have an error - Here's how to find out what is wrong

Invoke-ScriptAnalyzer  "C:\Users\mrrob\OneDrive\Documents\GitHub\$moduleName\$ModuleName.psd1"

## Lets fix that

Copy-Item $Presentation\BeardAnalysis.psd1 -Destination GIT:\$ModuleName\$ModuleName.psd1 -Force
git add .\$ModuleName.psd1
git commit -m "Fixed Script Analyzer Rules in psd1 file - Added specific values for Functions, Cmdlets and variables to export"

## So our code is written and tested locally and committed to our source control locally

## To deploy it to the PowerShell Gallery we need to set up VSTS

Start-Process https://sewells-consulting.visualstudio.com/PowerShell%20Gallery%20CI/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition`&id=14

## Disable trigger - save
## Reenable trigger

## Lets check the current PowerShell Gallery Version

Start-Process https://www.powershellgallery.com/packages/beardanalysis/

## Create a release notes file - Open Release Notes File and Alter

Get-ChildItem $Presentation\ReleaseNotes.txt | Copy-Item -Destination Git:\$ModuleName\docs

## So now with a sync to our version control server we can update our module and publish to the gallery

git add ./docs/ReleaseNotes.txt
git commit -m "Added Release Notes"
git push

## Now when we take a look at the VSTS we will see everything running through and publishing to the Gallery as we requested

Get-Module beardanalysis

Get-SpeakerBeard -Speaker RobSewell -Detailed -ShowImage

Get-SpeakerBeard -Top 5

Get-SpeakerBeard -Speaker LonnyNiederstadt -Detailed -ShowImage

## Just for fun :-)

## Just for fun

$url = 'https://newsqldbawiththebeard.files.wordpress.com/2017/04/wp_20170406_07_31_20_pro.jpg'

function JustForFun { Param($url)
$jsonBody = @{url = $url} | ConvertTo-Json
    $apiUrl = "https://westeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
    $apiKey = $Env:MS_Faces_Key
    $headers = @{ "Ocp-Apim-Subscription-Key" = $apiKey }
    $analyticsResults = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $jsonBody -ContentType "application/json"  -ErrorAction Stop
    $analyticsResults 
    $analyticsResults[0] | fl
    $analyticsResults[0].faceAttributes | select * |fl
    
    $Beard = $analyticsResults[0].faceAttributes.facialhair.beard

    Start-Process $url

    Write-Output "And the Beard Score is...........      $Beard"
}


$RobBeard = JustForFun $url

## I DO Have the Top Beard ;-)

## Lets have a look at Bill

$Bill = 'https://pbs.twimg.com/media/DNuGikFVAAIRWPO.jpg'

$BillBeard = JustForFun -url $Bill


