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



function Measure-SAObfuscation
{

<#
.SYNOPSIS

Measure-SAObfuscation simplifies the grouping and output of PSScriptAnalyzer rule matches created via Invoke-ScriptAnalyzer. These rules are designed to detect potential obfuscation in PowerShell scripts and commands, highlighting the power of PowerShell's AST (Abstract Syntax Tree) as a data source for creating targeted detection logic to help identify suspicious PowerShell code.

DevSec Defense Function: Measure-SAObfuscation
Author: Daniel Bohannon (@danielhbohannon)
License: Apache License, Version 2.0
Required Dependencies: Invoke-ScriptAnalyzer
Optional Dependencies: None
 
.DESCRIPTION

Measure-SAObfuscation simplifies the grouping and output of PSScriptAnalyzer rule matches created via Invoke-ScriptAnalyzer. These rules are designed to detect potential obfuscation in PowerShell scripts and commands, highlighting the power of PowerShell's AST (Abstract Syntax Tree) as a data source for creating targeted detection logic to help identify suspicious PowerShell code.

.PARAMETER Path

Specifies the path(s) to the PowerShell script to measure for obfuscation.

.EXAMPLE

C:\PS> $results = Measure-SAObfuscation -Path './Samples/Clean'

.EXAMPLE

C:\PS> $results = Measure-SAObfuscation -Path './Samples/Obfuscated/InvokeObfuscation'

.EXAMPLE

C:\PS> $results = Measure-SAObfuscation -Path './Samples/Obfuscated/InvokeCradleCrafter'

.EXAMPLE

C:\PS> $results = Measure-SAObfuscation -Path './Samples/Obfuscated/ISESteroids'

.NOTES

This is a personal project developed by Daniel Bohannon while an employee at MANDIANT, A FireEye Company.

.LINK

http://www.danielbohannon.com
#>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Path')]
        [Alias('File')]
        [System.String[]]
        $Path
    )
    
    # Read in file path as an expression.
    $fileList = Get-ChildItem $Path | Sort-Object

    $totalFiles = $fileList.Count
    
    $fileCount = 0
    $results = @()
    $results = $fileList | foreach-object {
        $fileCount++
        $curFile = $_.FullName
        
        $scriptAnalyzerResult = Invoke-ScriptAnalyzer -CustomRulePath .\PSScriptAnalyzer_Obfuscation_Detection_Rules.psm1 -Path $curFile
        
        # Output details of matching (or no matching) ScriptAnalyzer rule(s).
        $flagged = $false
        if ($scriptAnalyzerResult)
        {
            $flagged     = $true
            $hitCount    = ($scriptAnalyzerResult | Measure-Object).Count
            $uniqueRules = ($scriptAnalyzerResult | Group-Object RuleName).Count

            Write-Host "[*] ($fileCount of $totalFiles) Potentially Obfuscated :: $($_.Name)" -ForegroundColor Magenta
            
            # Output details of matching ScriptAnalyzer rule(s) grouped to save space.
            $scriptAnalyzerResult | Group-Object RuleName | Sort-Object Count -Descending | foreach-object {
                Write-Host "    [-] (count=$($_.Count)) $($_.Name)" -ForegroundColor Yellow
            
                $_.Group.Extent | Group-Object | Sort-Object Count,Name -Descending | foreach-object {
                    Write-Host "        (count=$($_.Count))`t" -NoNewLine
                    Write-Host $_.Name -ForegroundColor Cyan
                }
            }
        }
        else
        {
            Write-Host "[*] ($fileCount of $totalFiles) Clean :: $curFile" -ForegroundColor Green
        }

        # Return results as PSCustomObject.
        [PSCustomObject] @{
            Flagged = $flagged
            FileName = $curFile
            HitCount = $hitCount
            MatchingRules = $uniqueRules
            ScriptAnalyzerResult = $scriptAnalyzerResult
        }
    }

    $wasOrWere = 'were'
    if (($results | Where-Object { $_.Flagged } | Measure-Object).Count -eq 1)
    {
        $wasOrWere = 'was'
    }
    Write-Host ""
    Write-Host "[*] COMPLETED :: $(($results | Where-Object { $_.Flagged } | Measure-Object).Count) of $fileCount files $wasOrWere flagged as potentially obfuscated..." -ForegroundColor Green
    Write-Host ""

    # Return resultant array of PSCustomObjects.
    return $results
}