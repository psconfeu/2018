#requires -version 2.0
function ConvertTo-CliXml {
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [PSObject[]]$InputObject
    )
    begin {
        $type = [PSObject].Assembly.GetType('System.Management.Automation.Serializer')
        $ctor = $type.GetConstructor('instance,nonpublic', $null, @([System.Xml.XmlWriter]), $null)
        $sw = New-Object System.IO.StringWriter
        $xw = New-Object System.Xml.XmlTextWriter $sw
        $serializer = $ctor.Invoke($xw)
        $method = $type.GetMethod('Serialize', 'nonpublic,instance', $null, [type[]]@([object]), $null)
        $done = $type.GetMethod('Done', [System.Reflection.BindingFlags]'nonpublic,instance')
    }
    process {
        try {
            [void]$method.Invoke($serializer, $InputObject)
        } catch {
            Write-Warning "Could not serialize $($InputObject.GetType()): $_"
        }
    }
    end {    
        [void]$done.Invoke($serializer, @())
        $sw.ToString()
        $xw.Close()
        $sw.Dispose()
    }
}
