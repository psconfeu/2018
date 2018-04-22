# Search for patterns in format xml files
Select-String -path *.format.ps1xml -pattern Property, ScriptBlock -context 2 | Select-Object -first 5

# Wall of text!
# @lzybkr to the rescue. First sample of colorized matchinfos for select-string
# Quite heavily modified by me
Update-FormatData -PrependPath $demohome\MatchInfoV5.format.ps1xml
Select-String -path *.format.ps1xml -pattern PropertyName, '(?<green>ScriptBlock)' | Select-Object -first 5

# Let us head over to the PowerShell source code
cd $pssrc

# let's search the powershell source code:
Select-String -Path *.psm1 -Pattern "^function" | Select -first 40

# The power of colors. A wall of text again.
Get-Content $demohome\philosophy.txt

# But with a colored select-string:
# Valuable information that could otherwise get lost
# is clearly visible
$pattern = '(?<green>\bPo\w+)|(?<ye>\bI\b)|(?<re>\s[lkj]o.e)|(?<ma>.j.s.)'
Get-Content $demohome\philosophy.txt | Select-string -Pattern $pattern -CaseSensitive -Context 30

# load some color functions
. $demohome\colorfunctions.ps1
# Print 16 color table
color | Join-Item

# Print 256 color table
morecolor | Join-Item
morecolor -escapecode | Join-Item

# fake Print of 16 million color table
fullcolor

# quick reference - Get-PSReadlineOption
Get-PSReadlineOption

# https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
# Hurray! Finally PowerPoint time again!!
Invoke-Item $demohome\Formatting.pptx
exit
