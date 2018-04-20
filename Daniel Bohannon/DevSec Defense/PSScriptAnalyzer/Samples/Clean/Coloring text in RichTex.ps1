#code showing in RichTextBox
$code = @'
using System;
using System.Linq;
using System.Reflection;
using System.Diagnostics;

[assembly: AssemblyVersion("3.5.0.0")]

namespace ProcessesSortedWithStartTime {
  internal sealed class Program {
    static DateTime Started(Process p) {
      try {
        return p.StartTime;
      }
      catch {
        return DateTime.MinValue;
      }
    }

    static void Main() {
      Process[] procs = Process.GetProcesses();

      try {
        var sorted = from p in procs orderby Started(p), p.Id select p;
        foreach (Process p in sorted)
          Console.WriteLine("{0, 5} {1}", p.Id, p.ProcessName);
      }
      finally {
        foreach (Process p in procs)
          p.Dispose();
      }
    }
  }
}
'@

#reserved words
$res = @(
  "using", "namespace", "internal", "sealed", "class", "static", "try", "return", "catch",
  "void", "finally", "var", "from", "in", "orderby", "select", "foreach"
)

#invoke coloring
$frmMain_Load= {
  $res | % { Invoke-TextColoring $_ -col "Cyan" }
  #operation
  @("=") | % { Invoke-TextColoring $_ -col "Red" }
  #brackets
  "{", "}" | % { Invoke-TextColoring $_ -col "Orange" }
}

#coloring
function Invoke-TextColoring {
  param(
    [string]$Match,
    [int32]$Position = 0,
    [Windows.Forms.RichTextBoxFinds]$Options = "WholeWord",
    [Drawing.Color]$Color = "Blue"
  )

  $chk = $txtEdit.Find($match, $position, $options)

  while ($chk -ge 0) {
    $txtEdit.SelectionStart = $chk
    $txtEdit.SelectionLength = $match.Length
    $txtEdit.SelectionColor = $color

    $cur = $chk + $match.Length
    if ($cur -lt $txtEdit.TextLength) {
      $chk = $txtEdit.Find($match, $cur, $options)
    }
    else { break } #go out from cycle if there are not matches any more
  }
  $txtEdit.DeselectAll()
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()

  $frmMain = New-Object Windows.Forms.Form
  $txtEdit = New-Object Windows.Forms.RichTextBox
  #
  #txtEdit
  #
  $txtEdit.BackColor = [Drawing.Color]::FromArgb(1, 36, 86)
  $txtEdit.Dock = "Fill"
  $txtEdit.Font = New-Object Drawing.Font("Courier New", 10, [Drawing.FontStyle]::Bold)
  $txtEdit.ForeColor = [Drawing.Color]::Linen
  $txtEdit.Text = $code
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(590, 570)
  $frmMain.Controls.Add($txtEdit)
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "Form1"
  $frmMain.Add_Load($frmMain_Load)

  [void]$frmMain.ShowDialog()
}

frmMain_Show
