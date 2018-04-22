using System;
using System.Management.Automation;
using System.Collections.ObjectModel;

namespace PowerShellFromCSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            using (PowerShell ps = PowerShell.Create())
            {
                ps.AddCommand("Write-Output").AddParameter("InputObject", "Hello World from C#!");
                Collection<PSObject> PSOutput = ps.Invoke();
                foreach (PSObject outputItem in PSOutput)
                {
                    if (outputItem != null)
                    {
                        Console.WriteLine(outputItem);
                    }
                }
            }
        }
    }
}