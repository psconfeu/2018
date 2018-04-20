#   This file is part of DevSec Defense.
#
#   Copyright 2018 Daniel Bohannon <@danielhbohannon>
#         while at Mandiant <http://www.mandiant.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.



# Build regular expression matching detections.
$regexDetections  = @()
$regexDetections += 'DETECTION REGEX GOES HERE'

<#
$regexDetections += '\$PSHome\[\s*\d{1,3}\s*\]\s*\+\s*\$PSHome\['
$regexDetections += '\$ShellId\[\s*\d{1,3}\s*\]\s*\+\s*\$ShellId\['
$regexDetections += '\$env:Public\[\s*\d{1,3}\s*\]\s*\+\s*\$env:Public\['
$regexDetections += '\$env:ComSpec\[(\s*\d{1,3}\s*,){2}'
$regexDetections += '\*mdr\*\W\s*\)\.Name'
$regexDetections += '\$VerbosePreference\.ToString\('
$regexDetections += '\String\]\s*\$VerbosePreference'
#>

# Join regex terms to single regex.
$regex = '(' + ($regexDetections -join '|') + ')'

# Match unique results against regex.
$matched    = $uniqueSyntaxes -match $regex
$notMatched = $uniqueSyntaxes -notmatch $regex

Clear-Host

# Output all syntaxes that were NOT matched by regular expressions defined in $regexDetections above (i.e. are not being detected).
$notMatched

Write-Host ""
Write-Host "[*] Detection Rate: " -NoNewline -ForegroundColor Cyan
Write-Host "$([System.Math]::Round(100.0 * ([System.Double] $matched.Count / [System.Double] $uniqueSyntaxes.Count)))%" -NoNewline -ForegroundColor Yellow
Write-Host " (" -NoNewline -ForegroundColor Cyan
Write-Host $matched.Count -NoNewline -ForegroundColor Yellow
Write-Host " of " -NoNewline -ForegroundColor Cyan
Write-Host $uniqueSyntaxes.Count -NoNewline -ForegroundColor Yellow
Write-Host " syntaxes)" -ForegroundColor Cyan
Write-Host "[*] Regex: " -NoNewline -ForegroundColor Cyan
Write-Host $regex -ForegroundColor Yellow
Write-Host ""