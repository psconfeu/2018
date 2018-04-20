Function Get-StringHash([String] $String,$HashName = "MD5")
{
${/==\_/===\___/==\} = New-Object System.Text.StringBuilder
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
[Void]${/==\_/===\___/==\}.Append($_.ToString("x2"))
}
${/==\_/===\___/==\}.ToString()
}