# Source for setup: https://github.com/gerane/VSCodePresentations
# Tip:  Configure keyboard binding for Show Additional Commands from PowerShell Modules to Alt+P

Write-Host 'Configuring VS Code demo environment' -ForegroundColor Green

Register-EditorCommand `
    -Name 'Demo.OpenPowerPoint' `
    -DisplayName 'PSConfEU - Containers: Open PowerPoint' `
    -ScriptBlock {
        param([Microsoft.PowerShell.EditorServices.Extensions.EditorContext]$context)
        
        $Pptx = Join-Path -Path $($PSEditor.Workspace.Path) -ChildPath \presentation\*.pptx
        Invoke-Item -Path $Pptx
    }

    Register-EditorCommand `
    -Name 'Demo.OpenDemoFiles' `
    -DisplayName 'PSConfEU - Containers: Open demo-files' `
    -ScriptBlock {
        param([Microsoft.PowerShell.EditorServices.Extensions.EditorContext]$context)

        $Path = Join-Path -Path $($PSEditor.Workspace.Path) -ChildPath \demo\*.ps1
        Get-ChildItem -Path $Path -Recurse | Open-EditorFile
    }

    Register-EditorCommand `
    -Name 'Demo.Clean' `
    -DisplayName 'PSConfEU - Containers: Clean Docker environment' `
    -ScriptBlock {
        param([Microsoft.PowerShell.EditorServices.Extensions.EditorContext]$context)

        $Path = Join-Path -Path $($PSEditor.Workspace.Path) -ChildPath '\demo\00 - demo-cleanup\01 - clean-demo.ps1'
        & $Path
    }