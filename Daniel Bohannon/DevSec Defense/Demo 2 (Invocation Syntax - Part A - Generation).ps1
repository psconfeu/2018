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



# Invoke-Obfuscation invocation syntax generation.
# https://github.com/danielbohannon/Invoke-Obfuscation/blob/master/Out-ObfuscatedStringCommand.ps1#L873-L888

# Increase iteration count to more fully generate all possible syntaxes from code in loop below.
$iterations = 10

# Build an array of randomly-obfuscated invocation syntax.
$InvokeExpressionSyntax = @()
@(1..$iterations) | % {
    $InvocationOperator = (Get-Random -Input @('.','&')) + ' '*(Get-Random -Input @(0,1))
    $InvokeExpressionSyntax += $InvocationOperator + "( `$ShellId[1]+`$ShellId[13]+'x')"
    $InvokeExpressionSyntax += $InvocationOperator + "( `$PSHome[" + (Get-Random -Input @(4,21)) + "]+`$PSHome[" + (Get-Random -Input @(30,34)) + "]+'x')"
    $InvokeExpressionSyntax += $InvocationOperator + "( `$env:ComSpec[4," + (Get-Random -Input @(15,24,26)) + ",25]-Join'')"
    $InvokeExpressionSyntax += $InvocationOperator + "((" + (Get-Random -Input @('Get-Variable','GV','Variable')) + " '*mdr*').Name[3,11,2]-Join'')"
    $InvokeExpressionSyntax += $InvocationOperator + "( " + (Get-Random -Input @('$VerbosePreference.ToString()','([String]$VerbosePreference)')) + "[1,3]+'x'-Join'')"
    $InvokeExpressionSyntax += $InvocationOperator + "( `$env:Public[13]+`$env:Public[5]+'x')"
}

# Unique syntaxes.
$uniqueSyntaxes = $InvokeExpressionSyntax | Sort-Object -Unique
# Remove whitespace to further reduce data set.
#$uniqueSyntaxes = $InvokeExpressionSyntax | % { $_.Replace(' ','') } | Sort-Object -Unique

# Count of generated syntaxes.
$resultCount     = $InvokeExpressionSyntax.Count
$resultCountUniq = $uniqueSyntaxes.Count

Clear-Host
Write-Host ""
Write-Host "[*] Generated " -NoNewline -ForegroundColor Cyan
Write-Host $resultCount -NoNewline -ForegroundColor Yellow
Write-Host " invocation syntaxes..." -ForegroundColor Cyan
Write-Host "[*] Generated " -NoNewline -ForegroundColor Cyan
Write-Host $resultCountUniq -NoNewline -ForegroundColor Yellow
Write-Host " UNIQUE invocation syntaxes..." -ForegroundColor Cyan
Write-Host ""