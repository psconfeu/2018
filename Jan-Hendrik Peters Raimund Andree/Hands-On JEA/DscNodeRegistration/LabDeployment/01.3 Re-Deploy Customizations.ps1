$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

#-------------------------------------------------------------------------------------------------

Remove-LabVMSnapshot -AllMachines -SnapshotName 2
Restore-LabVMSnapshot -All -SnapshotName 1

Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -match '^\d{2} [\w ]+\.ps1' } | ForEach-Object {
    Write-Host "Calling script $($_.Name)..."
    
    & $_.FullName

    Write-Host "Finished with script $($_.Name)"
    Write-Host
}

Checkpoint-LabVM -All -SnapshotName 2