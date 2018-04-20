function Copy-MAGig
{
    param(
        [string]$src,
        [string]$dest,
        $exclude,
        [int]$width = 100,           # used with the -log switch to format the log, 
        [int]$ident = 2,             # dito
        [switch]$log,                # if -verbose had a nice format and its output could be redirected I wouldn't have to reinvent the wheel
        [switch]$summary,            # short log
        [switch]$Recurse,            
        [switch]$NoReplace,          # default is that source files overwrite existing files, files not replaced are not logged
        [switch]$keepEmptyFolders,   # default is no empty folder structures [you are not allowed to change this default]
        [switch]$newest              # not yet implemented , but not allowed together with -NoReplace, existing newer destination files are logged 
        
    )
    # By bernd Kriszio (twitter bernd_k)
    
    # The promlem with Copy-Item -Rec -Exclude is that -exclude effects only top-level files
    # Copy-Item $src $dest    -Exclude $exclude       -EA silentlycontinue -Recurse:$recurse
    # http://stackoverflow.com/questions/731752/exclude-list-in-powershell-copy-item-does-not-appear-to-be-working
    
    $errident = [math]::max($ident - 3, 0)
    $summaryident = [math]::max($ident - 4, 0)
    $src_pattern = "^$($src -replace '\\\\', '\\\\' )\\\\"
    try
    {
        if (Get-Item $src -EA stop)
        {
            if ($summary) {
                "{0,-$summaryident}{1,-$width} {2} => {3}" -f  '', $src , (@{'false'= '   ';'true'= 'rec' }[[string]$Recurse]), $dest
            }
            # nonstandard: I create destination directories on the fly
            [void](New-Item $dest -itemtype directory -EA silentlycontinue )
            Get-ChildItem -Path $src -Force -Rec:$Recurse -exclude $exclude | % {
                $relativePath =  $_.FullName -replace $src_pattern, ''
                if ($_.psIsContainer)
                {
                    if ($Recurse) # non standard: I don't want to copy directories, when not recurse
                    {
                        if ((Get-ChildItem $_.FullName |% { if (! $_.PSiscontainer) {$_} }) -or $keepEmptyFolders)
                        {
                            [void](New-item $dest\\$relativePath -type directory -ea silentlycontinue)
                        }
                    }
                }
                else
                {
                    $fileExists = Test-Path $dest\\$relativePath
                    if ($fileExists -and $newest) {
                        $leavecurrent =  $_.LastWriteTime -le (Get-item $dest\\$relativePath).LastWriteTime
                    } else {
                        $leavecurrent = $false
                    }
                    #"{0} {1} {2} {3}" -f $fileExists, $NoReplace, ($isnewer -and $newest), $relativePath
                    if ($log)
                    {
                        if ($fileExists) {
                            if (! $noreplace) {
                                if ($leavecurrent){
                                    "{0,-$errident}-- {1,-$width} => {2} (dest is current or newer)" -f  '', $_.FullName,  $dest
                                } else {
                                    "{0,-$ident}{1,-$width} => {2}" -f  '', $_.FullName,  $dest
                                }
                            }

                        } else {
                            "{0,-$ident}{1,-$width} -> {2}" -f  '', $_.FullName,  $dest
                        }
                    }
                    if ( ! ($fileExists -and ($NoReplace -or $leavecurrent))  )  {
                        try {
                            Copy-Item $_.FullName $dest\\$relativePath  -Force
                        } catch {
                            "{0,-$errident}## fail ##  {1}" -f '', $_.Exception.Message
                        }
                    }
                }

            }
        }
    }
    catch
    {
        "{0,-$errident}## fail ##  {1}" -f '', $_.Exception.Message
    }
}

