function Invoke-ShellActivity
{
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]$Path,
        
        [Parameter(Mandatory)]
        [string]$Verb
    )
    
    begin
    {
        $shell = New-Object -ComObject Shell.Application
    }
    
    process 
    {
        foreach ($p in $Path)
        {
            $parent = Split-Path -Path $p -Parent
            $leaf = Split-Path -Path $p -Leaf
        
            $shellFolder = $shell.NameSpace($parent)
        
            foreach ($item in $shellFolder.Items() | Where-Object Name -eq $leaf)
            {
                $verbDone = $false
                
                foreach ($v in $item.Verbs())
                {
                    if ($v.Name -eq $Verb)
                    {
                        $v.DoIt()
                        $verbDone = $true
                    }
                }
                
                if (-not $verbDone)
                {
                    Write-Error "Did not find the verb '$Verb' on object '$p'"
                }
            }
        }
    }
}