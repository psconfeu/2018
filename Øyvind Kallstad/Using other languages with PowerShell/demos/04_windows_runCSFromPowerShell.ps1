# running C# code from PowerShell
Set-Location "C:\Users\grave\Documents\github\_presentations\PowerShell_and_the_rest\demos"

# From file
Add-Type -Path "./hello.cs"
[MyNamespace.Hello]::SayHello()

# Inline
$csCode = @'
public static string SayHello()
{
    return "Hello World!";
}
'@

Add-Type -Name 'Hello' -Namespace 'MyNamespace2' -MemberDefinition $csCode
[MyNamespace2.Hello]::SayHello()