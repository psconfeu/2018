Configuration FilesAndFolders {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    #File 'TestFile_FilesAndFolders' {
    #    Ensure          = 'Present'
    #    DestinationPath = 'C:\TestFile_FilesAndFolders.txt'
    #    Contents        = ''
    #}

    foreach ($item in $Items) {
        if ($item.SourcePath) {
            File $item.DestinationPath {
                DestinationPath = $item.DestinationPath
                SourcePath      = $item.SourcePath
                Type            = $item.Type
                Ensure          = 'Present'
                Recurse         = $true
            }
        }
        else {
            File $item.DestinationPath {
                DestinationPath = $item.DestinationPath
                Contents = $item.Contents
                Type            = $item.Type
                Ensure          = 'Present'
            }
        }
    }
}