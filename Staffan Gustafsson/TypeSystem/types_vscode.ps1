$pscode = Search-Everything -Global -filter "PowerShell child:build.psm1 folder:"
[string] $root2018 = Resolve-Path "$PSScriptRoot\..\"
[string] $typesRoot = Join-Path $root2018 Types

Register-EditorCommand -Name "Types.OpenPowerPoint" -DisplayName 'Open TypeSystem Presentation' -SuppressOutput -ScriptBlock {
    Invoke-Item $PSScriptRoot\TypeSystem.pptx
}
Register-EditorCommand -Name "Types._OpenTypeAdapter" -DisplayName 'TypeAdapter' -SuppressOutput -ScriptBlock {  OpenAdapter }
Register-EditorCommand -Name "Types.10PsObject" -DisplayName '1: PSObject' -SuppressOutput -ScriptBlock {  PSObjectPwsh }
Register-EditorCommand -Name "Types.20AddMember" -DisplayName '2: Add-Member' -SuppressOutput -ScriptBlock {  AddMemberPwsh }
Register-EditorCommand -Name "Types.30UpdateTypeData" -DisplayName '3: Update-TypeData' -SuppressOutput -ScriptBlock {  UpdateTypeData }
Register-EditorCommand -Name "Types.40TypeAdaptor" -DisplayName '4: TypeAdaptor' -SuppressOutput -ScriptBlock {  TypeAdaptorPwsh }

function OpenAdapter {
    Open-EditorFile $typesRoot\BuildProjectAdapter\BuildProjectAdapter\BuildProjectAdapter.cs
}

function prompt {
    "> "
}
function PSObjectPwsh {
    pwsh -ReadLineHistory $typesRoot\PSObject.ps1 -Title "PSObject"
}

function AddMemberPwsh {
    pwsh -ReadLineHistory $typesRoot\AddMember.ps1 -Title "Add-Member"
}

function UpdateTypeData {
    pwsh -ReadLineHistory $typesRoot\UpdateTypeData.ps1 -Title "Update-TypeData"
}

function TypeAdaptorPwsh {
    pwsh -ReadLineHistory $typesRoot\TypeAdaptors.ps1 -Title "Type Adaptors"
}

function pwsh {
    param(
        [Parameter(Mandatory)]
        [string] $ReadLineHistory
        ,
        [string] $Title = "Demo"
        ,
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Prompt
    )

    & $cmd -WindowStyle Maximized -NoExit -File $root2018\profile.ps1  @PSBoundParameters -Presentation TypeSystem
}
