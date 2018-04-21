
function color {
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateRange(30, 97)]
        [int[]] $index = $((30..37) + (90..97))
        ,
        [string] $text = "PSConfEU 2018",
        [switch] $EscapeCode
    )
    # `e[<30-37>m or `e[<90-97>m
    foreach ($i in $index) {
        if ($EscapeCode) {
            "`e[{0}m``e[{0}m {1} ``e[0m`e[0m" -f $i, $text
        }
        else {
            "`e[{0}m{1}`e[0m" -f $i, $text
        }
    }
}

function morecolor {
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $index = 0..255
        ,
        [string] $text = "PSConfEU 2018",
        [switch] $EscapeCode
    )
    process {
        foreach ($i in $index) {
            if ($EscapeCode) {
                # "`e[48;5; for background
                "`e[38;5;{0}m``e[38;5;{0}m {1} ``e[0m`e[0m" -f $i, $text
            }
            else {
                # "`e[48;5; for background
                "`e[38;5;{0}m{1}`e[0m" -f $i, $text
            }
        }
    }
}

function fullcolor {
    param(
        [string] $text = "PSConfEU2018 ",
        [switch] $EscapeCode,
        [switch] $Force
    )
    end {
        $width = $host.UI.RawUI.BufferSize.Width
        $bufferSize = 1000 * $width
        $sb = [Text.StringBuilder]::new($bufferSize)
        $a = 0..255 | Where-Object {$Force -or ($_ % 10 -eq 0)}
        $sb.AppendLine()
        foreach ($g in $a) {
            foreach ($b in $a) {
                foreach ($r in $a) {
                    if ($EscapeCode) {
                        # "`e[48;2; for background
                        $formatted = "`e[38;2;{0};{1};{2}m``e[38;2;{0};{1};{2}m {3} ``e[0m`e[0m" -f $r, $g, $b, $text
                        $sb.Append($formatted)   | Out-Null
                    }
                    else {
                        # "`e[48;2; for background
                        $formatted = "`e[38;2;{0};{1};{2}m{3}`e[0m" -f $r, $g, $b, $text
                        $sb.Append($formatted) | Out-Null
                    }
                }
            }
        }
        $sb.ToString()
    }
}
