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



#################################################################
##                                                             ##
## Rules for detecting potentially obfuscated PowerShell code. ##
##                                                             ##
#################################################################

# Note: This is a personal project developed by Daniel Bohannon while an employee at MANDIANT, A FireEye Company.

<#
.DESCRIPTION
    Finds instances of commands with back ticks, which can be used to
    obfuscate the command to evade static analysis IOC matching.
#>
function Measure-TickUsageInCommand
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds CommandAst nodes (first element) that contain one or more back ticks.
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)

        $targetAst = $Ast -as [System.Management.Automation.Language.CommandAst]
        if ($targetAst)
        {
            if ($targetAst.CommandElements[0].Extent.Text -cmatch '`')
            {
                return $true
            }
        }
    }
    
    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via back tick in command: " + $foundNode.CommandElements[0].Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}

<#
.DESCRIPTION
    Finds instances of arguments with back ticks before non-escapable
    characters, which can be used to obfuscate the argument to evade
    static analysis IOC matching.
#>
function Measure-TickUsageInArgument
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds CommandAst nodes (second element for the argument of the command) that contain one or more back ticks (preceding a non-escapable character).
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)
        
        $targetAst = $Ast -as [System.Management.Automation.Language.CommandAst]
        if ($targetAst)
        {
            if (($targetAst.CommandElements[1].Extent.Text -cmatch '`[a-zA-Z1-9\-\.]') -and ($targetAst.CommandElements[1].Extent.Text -cnotmatch '`[abfnrtvx]'))
            {
                return $true
            }
        }
    }
    
    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via back tick in front of unescapable characters in argument: " + $foundNode.CommandElements[1].Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}

<#
.DESCRIPTION
    Finds instances of members with back ticks, which can be used to
    obfuscate the member to evade static analysis IOC matching.
#>
function Measure-TickUsageInMember
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds MemberExpressionAst nodes that contain one or more back ticks.
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)

        $targetAst = $Ast -as [System.Management.Automation.Language.MemberExpressionAst]
        if ($targetAst)
        {
            if ($targetAst.Member.Extent.Text -cmatch '`')
            {
                return $true
            }
        }
    }
    
    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via back tick in member: " + $foundNode.Member.Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}

<#
.DESCRIPTION
    Finds instances of members with non-alphanumeric characters,
    which can be used to obfuscate the member to evade static 
    analysis IOC matching.
#>
function Measure-NonAlphanumericUsageInMember
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds MemberExpressionAst nodes that contain non-alphanumeric characters.
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)

        $targetAst = $Ast -as [System.Management.Automation.Language.MemberExpressionAst]
        if ($targetAst)
        {
            if ($targetAst.Member.Extent.Text.Trim('"''()').TrimStart('$#') -cmatch '[^a-zA-Z0-9\.\s\-_\[\]]')
            {
                return $true
            }
        }
    }
    
    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via non-alphanumeric character(s) in member: " + $foundNode.Member.Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}

<#
.DESCRIPTION
    Finds instances of variables with adjacent special characters,
    which can be used to obfuscate the variable names to evade
    static analysis IOC matching.
#>
function Measure-NonAlphanumericUsageInVariable
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds VariableExpressionAst nodes that contain 3+ adjacent non-alphanumeric characters.
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)

        $targetAst = $Ast -as [System.Management.Automation.Language.VariableExpressionAst]
        if ($targetAst)
        {
            if ($targetAst.VariablePath.UserPath -cmatch '[^a-zA-Z0-9]{4}|[^a-zA-Z0-9:][^a-zA-Z0-9_][^a-zA-Z0-9]')
            {
                return $true
            }
        }
    }

    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via special-character-only variable name of: " + $foundNode.Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}

<#
.DESCRIPTION
    Finds instances of members with unusually long values,
    which can be indicative of substitution-style obfuscation
    (like that produced by Invoke-CradleCrafter) which can be
    used to evade static analysis IOC matching.
#>
function Measure-LongMemberValue
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    
    # Finds MemberExpressionAst nodes that are unusually long.
    [ScriptBlock] $predicate = {
        param ([System.Management.Automation.Language.Ast] $Ast)

        $targetAst = $Ast -as [System.Management.Automation.Language.MemberExpressionAst]
        if ($targetAst)
        {
            if (($targetAst.Member.Extent.Text.Length -gt 35) -or (($targetAst.Member.Extent.Text -cmatch '[^a-zA-Z0-9\$\._\"\'']') -and ($targetAst.Member.Extent.Text.Length -gt 25)))
            {
                return $true
            }
        }
    }
    
    $foundNodes = $ScriptBlockAst.FindAll($predicate, $true)
    foreach ($foundNode in $foundNodes)
    {
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] @{
            "Message"  = "Possible obfuscation found via excessively long member value: (length=$($foundNode.Member.Extent.Text.Length)) " + $foundNode.Member.Extent.Text
            "Extent"   = $foundNode.Extent
            "RuleName" = "MaliciousContent." + $PSCmdlet.MyInvocation.InvocationName.Split('-')[-1]
            "Severity" = "Warning"
        }
    }
}