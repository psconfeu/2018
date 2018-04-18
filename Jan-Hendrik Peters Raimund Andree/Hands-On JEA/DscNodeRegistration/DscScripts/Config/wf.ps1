workflow wf
{
    param
    (
        $ComputerName
    )

    $items = Get-ChildItem C:\ -Recurse

    Checkpoint-Workflow

    foreach -parallel ($C in $ComputerName)
    {
        Install-WindowsFeature -ComputerName $c -Name RSAT-AD-Tools
    }

    Checkpoint-Workflow
    throw "fehler"
    parallel
    {
        Stop-Computer $ComputerName -PSPersist $true
        Start-Vm $ComputerName
    }

    sequence
    {

    }
}

Resume-Job