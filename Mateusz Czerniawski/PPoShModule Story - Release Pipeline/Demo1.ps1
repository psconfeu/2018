throw "Don't run with scissors"

#region Demo1
#region initilize LocalFolders
$DemoFolder = 'C:\AdminTools\Tests\PPoShModuleStory'
$DemoName = 'Demo'
$DemoFullPath = Join-Path -Path $DemoFolder -ChildPath $DemoName

if(!$DemoFolder) {
  $null = (New-Item -Path $DemoFolder -ItemType Directory)
}
#endregion
#region Demo how to create Repo on GitHub
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo1_GitHub.mp4')
#endregion

#endregion

#region Demo2a - GitHub + Plaster
#region Initialize Repo
code 
$GitRepo = 'https://github.com/PPOSHGROUP/PPoShDemo'
git clone $GitRepo $DemoFullPath

$PlasterTemplate = Join-Path -Path $DemoFolder -ChildPath 'PlasterTemplate'
Invoke-Plaster -TemplatePath $PlasterTemplate -DestinationPath $DemoFullPath 

#Change GUID
#Remove Readme.md.bak

Set-Location -Path $DemoFullPath
git add .
git commit -m 'initial version'
git push
#endregion
#region Invoke Demo File
code $PlasterTemplate
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo2_PlasterPPoSh.mp4')
#endregion
#endregion

#region Demo2b - Git + Plaster
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo3_Git.mp4') 

$DemoFolder = 'C:\AdminTools\Tests\ReleasePipeline'
$GitObjRepo = 'https://mczerniawski@git-it.objectivity.co.uk/r/AdminPSModules/Objectivity.Demo.git'
$DemoObjName = 'Objectivity.Demo'
$DemoObjFullPath = Join-Path -Path $DemoFolder -ChildPath $DemoObjName
git clone $GitObjRepo $DemoObjFullPath

$PlasterTemplate = Join-Path -Path $DemoFolder -ChildPath 'ObjectivityModuleTemplate'
Invoke-Plaster -TemplatePath $PlasterTemplate -DestinationPath $DemoObjFullPath 

#Remove Readme.md.bak

Set-Location -Path $DemoObjFullPath
git add .
git commit -m 'initial version'
git push
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo4_PlasterObj.mp4')
#endregion


#region Demo3
#region Configure AppVeyor
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo5_AppVeyor.mp4')
#endregion

#endregion

#region Demo4
#region Copy Final Files
$DemoFinalName = 'PPoShDemoFinal'
$DemoFinalPath = Join-Path -Path $DemoFolder -ChildPath $DemoFinalName
Copy-Item -Path "$DemoFinalPath\PPoShDemo\Public\*.*" -Destination "$DemoFullPath\PPoShDemo\Public\"  -Recurse -Force
git add .
git commit -m 'final demo files'
git push
#endregion
#region PPoShDemo Final
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo6_PSGallery.mp4')
#endregion
#endregion

#region Demo5
#region Create Wiki
$GitRepoWiki = 'https://github.com/PPOSHGROUP/PPoShDemo.wiki'
$GitLocalRepoWiki = Join-Path -Path $DemoFolder -ChildPath 'PPoShDemo.wiki'
git clone $GitRepoWiki $GitLocalRepoWiki

Set-Location -Path $DemoFullPath
.\build\build.ps1
Set-Location -Path $GitLocalRepoWiki
git add .
git commit -m 'Wiki Files'
git push
#endregion
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo7_Wiki.mp4')
#endregion


#region TeamCity Project
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo8_TCProject.mkv')
#endregion
#region Deploy to servers
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo9_Deploy.mkv')
#endregion
#region Simple File Watcher
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo10_SimpleFile.mkv') 
#endregion
#region Current State
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo11_CurrentState.mkv') 
#endregion
#region Naming Schemes
Invoke-Item (Join-Path $DemoFolder -ChildPath 'Demo\Demo12_NamingScheme.mkv') 
#endregion