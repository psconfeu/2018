<#
.SYNOPSIS
   Converts data from flat or single-level property files into PSObjects
.DESCRIPTION
   Converts delimited string data such as .ini files, or the format-list output of PowerShell, into objects
.EXAMPLE
   netsh http show sslcert | join-string "`n" | 
   ConvertFrom-PropertyString -ValueSeparator " +: " -AutomaticRecords |
      Format-Table Application*, IP*, Certificate*
            
   Converts the output of netsh show into pseudo-objects, and then uses Format-Table to display them
.EXAMPLE
   ConvertFrom-PropertyString config.ini
   
   Reads in an ini file (which has key=value pairs), using the default settings

   .EXAMPLE
   @"
   ID:3468
   Type:Developer
   StartDate:1998-02-01
   Code:SWENG3
   Name:Baraka

   ID:11234
   Type:Management
   StartDate:2005-05-21
   Code:MGR1
   Name:Jax
   "@ |ConvertFrom-PropertyString -sep ":" -RecordSeparator "\\r\\n\\s*\\r\\n" | Format-Table


   Code             StartDate       Name            ID              Type           
   ----             ---------       ----            --              ----           
   SWENG3           1998-02-01      Baraka          3468            Developer      
   MGR1             2005-05-21      Jax             11234           Management     
      
   Reads records from a key:value string with records separated by blank lines.
   NOTE that in this example you could also have used -AutomaticRecords or -Count 5 instead of specifying a RecordSeparator
.EXAMPLE
   @"
   Name=Fred
   Address=Street1
   Number=123
   Name=Janet
   Address=Street2
   Number=345 
   "@ | ConvertFrom-PropertyString -RecordSeparator "`n(?=Name=)"

   Reads records from a key=value string and uses a look-ahead record separator to start a new record whenever "Name=" is encountered
   
   NOTE that in this example you could have used -AutomaticRecords or -Count 3 instead of specifying a RecordSeparator 
.EXAMPLE
   ConvertFrom-PropertyString data.txt -ValueSeparator ":"
   
   Reads in a property file which has key:value pairs
.EXAMPLE
   Get-Content data.txt -RecordSeparator "`r`n`r`n" | ConvertFrom-PropertyString -ValueSeparator ";"
   
   Reads in a property file with key;value pairs, and records separated by blank lines, and converts it to objects
.EXAMPLE
   ls *.data | ConvertFrom-PropertyString
   
   Reads in a set of *.data files which have an object per file defined with key:value pairs of properties, one-per line.
.EXAMPLE
   ConvertFrom-PropertyString data.txt -RecordSeparator "^;(.*?)\\r*\\n" -ValueSeparator ";"
   
   Reads in a property file with key:value pairs, and sections with a header that starts with the comment character ';'
   
.NOTES
   3.6   2013 Apr 6
         - Add AllowEmptyValue parameter to supports data that just has a header and a list of properties (without values)
   3.5   2012 July 26
         - Changed defaults so that lines which don't have a -ValueSeparator in them don't get output
         - Changed pipelining so that it works more the way I expect it to, nowadays
         - Fixed some problems with -RecordSeparator getting truncated to a single character when you use a capture group and add it as a PSName property
         Clearly I need to write some test cases around this to make sure that I'm not breaking functionality, because these changes felt like things that should have already worked...
   3.0   2010 Aug 4 
         - Renamed most of the parameters because I couldn't tell which did what from the Syntax help
         - Added a -AutomaticRecords switch which creates new output objects whenevr it encounters a duplicated property
         - Added a -SimpleOutput swicth which prevents the output of the PSChildName property
         - Added a -CountOfPropertiesPerRecord parameter which allows splitting input by count instead of regex or automatic
   2.0   2010 July 9 http://poshcode.org/get/1956
         - changes the output so that if there are multiple instances of the same key, we collect the values in an array
   1.0   2010 June 15 http://poshcode.org/get/1915
         - Initial release
#>
# function ConvertFrom-PropertyString {
[CmdletBinding(DefaultParameterSetName="Data")]
param(
   # The text to be parsed
   [Parameter(Position=99, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Data")]
   [Alias("Data","Content","IO")]
   [AllowEmptyString()]
   [string]$InputObject,

   # A file containing text to be parsed (so you can pipeline files to be processed)
   [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="File")]
   [Alias("PSPath")]
   [string]$FilePath,

   # The value separator string used between name=value pairs. Allows regular expressions.
   # Typical values are "=" or ":"
   # Defaults to "="   
   [Parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false)]
   [Alias("VS","Separator")]
   [String]$ValueSeparator="\\s*(?:=|:)\\s*",

   # The property separator string used between sets of name=value pairs. Allows regular expressions.
   # Typical values are "\\n" or "\\n\\n" or "\\n\\s*\\n"
   # Defaults to "\\n\\s*\\n?"    
   [Parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false)]
   [Alias("PS","Delimiter")]
   [String]$PropertySeparator='(?:\\s*\\n+\\s*)+',

   # The record separator string is used between records or sections in a text file.
   # Typical values are "\\n\\s*\\n" or "\\n\\[(.*)\\]\\s*\\n"
   # Defaults to "(?:\\n|^)\\[([^\\]]+)\\]\\s*\\n" (the correct value for ini files).
   
   # To support named sections or records, make sure to use a regular expression here that has a capture group defined.
   [Parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false)]
   [Alias("RS")]
   [String]$RecordSeparator='(?:\\n|^)\\[([^\\]]+)\\]\\s*\\n',
   
   # Supports guessing when a new record starts based on the repetition of a property name. You can use this whenever your input has multiple records and the properties are always in the same order.
   [Parameter(ParameterSetName="Data")]
   [Alias("MultiRecords","MR","MultipleRecords","AR","AutoRecords")]
   [Switch]$AutomaticRecords,
   
   # Separate the input into groups of a certain number of properties.
   # If your input file has no specific record separator, you can usually match the first property by using a look-ahead expression *(See Example 2)*
   # However, if the properties aren't in the same order each time or regular expressions make you queasy, and each of your records have the same number of properties on each record, you can use this to separate them by count.   
   [Parameter()]
   [int]$CountOfPropertiesPerRecord,
   
   # Prevent outputting the PSName parameter which indicates the source of the object when pipelineing file names
   [Parameter()]
   [Switch]$SimpleOutput,
   
   # Discard the first record, assuming that it is merely some lines of header introductory text
   [Parameter()]
   [Switch]$HasHeader,
   
   # Discard the last record, assuming that it is merely some lines of footer summary text
   [Parameter()]
   [Switch]$HasFooter,

   # Allow Empty Values if there's no value separator
   [switch]$AllowEmptyValue
)
begin {
   function new-output {
      [CmdletBinding()]
      param(
         [Switch]$SimpleOutput
      ,
         [AllowNull()][AllowEmptyString()]
         [String]$Key
      ,
         [AllowNull()][AllowEmptyString()]
         $FilePath
      )
      end {
         if(!$SimpleOutput -and ("" -ne $Key))  { @{"PSName"=$key} }
         elseif(!$SimpleOutput -and $FilePath)  { @{"PSName"=((get-item $FilePath).PSChildName)} }
         else                                   { @{} }
      }
   }

   function out-output {
      [CmdletBinding()]
      param([Hashtable]$output)
      end {
         ## If we made arrays out of single values, unwrap those
         foreach($k in $Output.Keys | Where { @($Output.$_).Count -eq 1 } ) {
            $Output.$k = @($Output.$k)[0]
         }
         if($output.Count) {
            New-Object PSObject -Property $output
         }
      }
   }
   $OutputCount = 0
   [String]$InputString = [String]::Empty

   Write-Verbose "Setting up the regular expressions: `n`tRecord:   '$RecordSeparator'  `n`tProperty: '$PropertySeparator'  `n`tValue:    '$ValueSeparator'"
   [Regex]$ReRecordSeparator   = New-Object Regex ([System.String]"\\s*$RecordSeparator\\s*"),   ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   [Regex]$RePropertySeparator = New-Object Regex ([System.String]"\\s*$PropertySeparator\\s*"), ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   [Regex]$ReValueSeparator    = New-Object Regex ([System.String]"\\s*$ValueSeparator\\s*"),    ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
}
process {
   if($PSCmdlet.ParameterSetName -eq "File") {
      $AutomaticRecords = $true
      $InputString += $(Get-Content $FilePath -Delimiter ([char]0)) + "`n`n"
   } else {
      $InputString += "$InputObject`n"
   }
}
end {
   ## some kind of PowerShell bug when expecting pipeline input:   
   if(!"$ReRecordSeparator"){
      Write-Verbose "Setting up the record regex in the PROCESS block: '$RecordSeparator'"
      [Regex]$ReRecordSeparator   = New-Object Regex ([System.String]"\\s*$RecordSeparator\\s*"),   ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   }
   if(!"$RePropertySeparator"){
      Write-Verbose "Setting up the property regex in the PROCESS block: '$PropertySeparator'"
      [Regex]$RePropertySeparator = New-Object Regex ([System.String]"\\s*$PropertySeparator\\s*"), ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   }
   if(!"$ReValueSeparator") {  
      Write-Verbose "Setting up the value regex in the PROCESS block: '$ValueSeparator'"
      [Regex]$ReValueSeparator    = New-Object Regex ([System.String]"\\s*$ValueSeparator\\s*"),    ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   }
   Write-Verbose "ParameterSet: $($PSCmdlet.ParameterSetName)"
   Write-Verbose "ValueSeparator: $($ReValueSeparator)"
   $InputData = @{}
   if($PSCmdlet.ParameterSetName -eq "File") {
      $AutomaticRecords = $true
      $InputString = Get-Content $FilePath -Delimiter ([char]0)
   }
   
   ## Separate RecordText with the RecordSeparator if the user asked us to:
   if($PsBoundParameters.ContainsKey('RecordSeparator') -or $AutomaticRecords ) {
      $Records = $ReRecordSeparator.Split( $InputString ) # | Where-Object { $_ }
      ## Instead of using WhereObject and removing all the empty rows, allow empties AFTER record separators, but not before...
      if(!@($Records)[0]) {
         $Records = $Records[1..$($Records.Count-1)]
      }
      Write-Verbose "There are $($ReRecordSeparator.GetGroupNumbers().Count) groups and $(@($Records).Count) records!"
      if($ReRecordSeparator.GetGroupNumbers().Count -gt 1 -and @($Records).Count -gt 1) {
         if($HasHeader) {
            $Records = $Records[2..$($Records.Count -1)]
         }
         if($HasFooter) {
            $Records = $Records[0..$($Records.Count -3)]
         }
         while($Records) {
            $Key,$Value,$Records = @($Records)
            Write-Verbose "RecordSeparator with grouping: $Key = $Value"
            $InputData.$Key += @($Value)
         }
      } elseif(@($Records).Count -gt 1) {
         $InputData."" = @($Records)
         $InputString = $Records
      } else {
         $InputString = $Records
      }
   }
      
   ## Separate RecordText into properties and group them together by count if we were told a count
   if($PsBoundParameters.ContainsKey('CountOfPropertiesPerRecord')) {   
      $Properties = $RePropertySeparator.Split($InputString)
      Write-Verbose "Separating Records by Property count = $CountOfPropertiesPerRecord of $($Properties.Count)"
      for($Index = 0; $Index -lt $Properties.Count; $Index += $CountOfPropertiesPerRecord) {
         $InputData."" += @($Properties[($Index..($Index+$CountOfPropertiesPerRecord-1))] -Join ([char]0))
         Write-Verbose "Record ($Index..) $($Index/$CountOfPropertiesPerRecord) = $(@($Properties[($Index..($Index+$CountOfPropertiesPerRecord-1))] -Join ([char]0)))"
      }
      ## We have to manually set the PropertySeparator because we can't generate text from your regex pattern to match your regex pattern
      $SetPropertySeparator = $RePropertySeparator
      [Regex]$RePropertySeparator = New-Object Regex ([System.String][char]0), ([System.Text.RegularExpressions.RegexOptions]"Multiline,IgnoreCase,Compiled")
   } 
   if($InputData.Keys.Count -eq 0){
      Write-Verbose "Keyless entry enabled!"
      $InputData."" = @($InputString)
   }
   
   Write-Verbose "InputData: $($InputData.GetEnumerator() | ft -auto -wrap| out-string)"

   ## Process each Record
   foreach($key in $InputData.Keys) { foreach($record in $InputData.$Key) {
      Write-Verbose "Record($Key): $record"
      
      $output = new-output -SimpleOutput:$SimpleOutput -Key:$Key -FilePath:$FilePath
      
      foreach($Property in $RePropertySeparator.Split("$record") | ? {$_}) {
         if($ReValueSeparator.IsMatch($Property)) {
            [string[]]$data = $ReValueSeparator.split($Property,2) | foreach { $_.Trim() } | where { $_ }
            Write-Verbose "Property: $Property --> $($data -join ': ')"
            if($AutomaticRecords -and $Output.ContainsKey($Data[0])) {
               out-output $output
               $output = new-output -SimpleOutput:$SimpleOutput -Key:$Key -FilePath:$FilePath
            }
            switch($data.Count) {
               1 { $output.($Data[0]) += @($null)    }
               2 { $output.($Data[0]) += @($Data[1]) }
            }
         } elseif($AllowEmptyValue) {
            $output.$Property = $true
         }
      }
      out-output $output

      
   }  }
   ## Put this back in case there's more input
   $RePropertySeparator = $SetPropertySeparator
}
#}
