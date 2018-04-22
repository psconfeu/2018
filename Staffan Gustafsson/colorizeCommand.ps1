using namespace System.Management.Automation.Language
using namespace System.Collections.Generic

# helper functions to colorize powershell code the same way PSReadline would
# Uses the tokenizer to get the pieces to color

class TokenOffsetColor {
    [Token] $Token
    [int] $StartOffset
    [int] $EndOffset
    [string] $Text
    [string] $Color

    [string] ToString() {
        return "{0} ({1})" -f $this.Text, $this.Token.Kind
    }
}

class ColoredChar {
    [string] $Char
    [int] $OriginalOffset

    [string] ToString() {
        return $this.Char
    }
}

class Colorizer {
    static SetTokenColors($o) {
        [Colorizer]::TokenColors = @{
            [TokenKind]::Command = $o.CommandColor
            [TokenKind]::Variable = $o.VariableColor
            [TokenKind]::StringExpandable = $o.StringColor
            [TokenKind]::StringLiteral = $o.StringColor
            [TokenKind]::Parameter = $o.ParameterColor
            [TokenKind]::Comment = $o.CommentColor
            [TokenKind]::Number = $o.NumberColor
            [TokenKind]::Type = $o.TypeColor
            [TokenKind]::Cmatch = $o.OperatorColor
            [TokenKind]::If = $o.KeywordColor
            [TokenKind]::EndOfInput = $o.DefaultTokenColor
        }
        [Colorizer]::DefaultTokenColor = $o.DefaultTokenColor
    }
    static [Hashtable] $TokenColors
    static $DefaultTokenColor

    static [void] colorizeToken([TokenOffsetColor] $TokenOffsetColor) {
        $token = $TokenOffsetColor.Token
        $tokcol = [Colorizer]::TokenColors
        $dc = [Colorizer]::DefaultTokenColor
        $c = switch ($token) {
            {$token.TokenFlags -match 'Operator'} {
                $tokcol[[TokenKind]::Cmatch]
            }
            {$token.TokenFlags -match 'Keyword'} {
                $tokcol[[TokenKind]::If]
            }
            {$token.TokenFlags -eq 'CommandName'} {
                $tokcol[[TokenKind]::Command]
            }
            default {
                $c = $tokcol[$token.Kind]
                if (!$c) {
                    $c = $dc
                }
                $c
            }
        }
        $TokenOffsetColor.Color = $c
    }

    static [string] ToColorizedString([TokenOffsetColor[]] $TokenOffsetColors) {
        if (-not $tokenOffsetColors) {
            return ""
        }
        $dc = [Colorizer]::DefaultTokenColor
        $b = [System.Text.StringBuilder]::new($TokenOffsetColors[-1].EndOffset * 2)
        $prevEndOffset = 0
        foreach ($TokenOffsetColor in $TokenOffsetColors) {
            if ($TokenOffsetColor.StartOffset -ne $prevEndOffset) {
                $b.Append("$dc ")
            }
            $b.Append($TokenOffsetColor.Color)
            $b.Append($TokenOffsetColor.Text)
            $prevEndOffset = $TokenOffsetColor.EndOffset
        }
        $b.Append("`e[39;49m") | out-null
        return $b.ToString()
    }

    static [ColoredChar[]] ToColorizedCharacters([TokenOffsetColor[]] $tokenOffsetColors) {
        if (-not $tokenOffsetColors) {
            return @()
        }
        $dc = [Colorizer]::DefaultTokenColor
        $colored = [List[ColoredChar]]::new(128)
        $prevEndOffset = 0
        foreach ($token in $tokenOffsetColors) {
            $start = $token.StartOffset
            for ($i = $prevEndOffset; $i -lt $start; $i++ ) {
                $cc = [ColoredChar] @{
                    Char = "$dc "
                    OriginalOffset = $i
                }
                $colored.Add($cc)
            }
            $tokenChars = $token.Text.ToCharArray()
            $start = $token.StartOffset
            for ($i = 0; $i -lt $tokenChars.Length; $i++ ) {
                $ccText = "{0}{1}" -f $token.Color, $tokenChars[$i]
                $cc = [ColoredChar] @{
                    Char = $ccText
                    OriginalOffset = $start + $i
                }
                $colored.Add($cc)
            }
            $prevEndOffset = $token.EndOffset
        }
        $cc = [ColoredChar] @{
            Char = $dc
            OriginalOffset = $tokenOffsetColors[-1].EndOffset
        }
        $colored.Add($cc)
        return $colored
    }

    static [string] GetColorizedString([string] $command) {
        $tokens = [Colorizer]::Tokenize($command)
        foreach ($t in $tokens) {
            [Colorizer]::colorizeToken($t)
        }
        return [Colorizer]::ToColorizedString($tokens)
    }

    static [ColoredChar[]] GetColorizedCharacters([string] $command) {
        $tokens = [Colorizer]::Tokenize($command)
        foreach ($t in $tokens) {
            [Colorizer]::colorizeToken($t)
        }
        return [Colorizer]::ToColorizedCharacters($tokens)
    }

    static [TokenOffsetColor[]] Tokenize([string] $command) {
        $tokens = $errors = $null
        $null = [Parser]::ParseInput($command, [ref] $tokens, [ref] $errors )

        function emitToken([Token]$t, [int]$st, [int]$end) {
            if ($st -ne $end) {
                [TokenOffsetColor] @{
                    Token = $t
                    StartOffset = $st
                    EndOffset = $end
                    Text = $Command.Substring($st, $end - $st)
                }
            }
        }
        function enumTokens($token, $s, $e) {

            $start = $s
            $end = $e
            $n = $token.NestedTokens

            $previousStart = $start
            $previousEnd = $start
            foreach ($nested in $n) {
                $ext = $nested.Extent
                $start = $ext.StartOffset
                $end = $ext.EndOffset
                if ($start -ne $previousStart) {
                    emitToken $token $previousEnd ($start)
                    $previousStart = $start
                    $previousEnd = $end
                }

                $start = $ext.StartOffset
                $end = $ext.EndOffset
                enumTokens $nested $start $end
                $previousStart = $start
                $previousEnd = $end
            }
            emitToken $token $previousEnd $e
        }
        $res = foreach ($t in $tokens) {
            enumTokens $t $t.Extent.StartOffset $t.Extent.EndOffset
        }
        return $res
    }
}

$o = Get-PSReadLineOption
[Colorizer]::SetTokenColors($o)

function colorize([string] $command) {
    [Colorizer]::GetColorizedString($command)
}

function colorizeCharacters([string] $command) {
    [Colorizer]::GetColorizedCharacters($command)
}
# tokenizeCommand 'gci -path a$b\c$d\e'
# colorize 'gci -path a$b\c$d\e'