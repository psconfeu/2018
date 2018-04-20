function Combine-CSV{
<#
	.Synopsis
	
 	 Combines similar CSV files into a single CSV File
	 
	.Description 
	 Function will combine common .CSV files into one large file.  CSV files should have same header.
	 This script is intended to aid when doing large reports across a large environment.
	 
	.Parameter SourceFolder
	
	 Specifies the folder location for the .CSV files.  If no filter is applied it will combine all 
	 .CSV files in that directory.
	 
	.Parameter Filter
	 
	 Specifies any filtering used for Get-ChildItem when grabbing the list of files to be combined.
	 
	.Parameter ExportFileName
	 
	 Specifies the file to have the combined .CSV files exported.  The combined file will be placed
	 into the same directory as the SourceFolder
	
	.Example
	
	 Combine-CSV -SourceFolder "C:\\Temp\\" -Filter "vcm*.csv" -ExportFileName "All-VCM.csv"
	 
	 This will combine all .CSV files in directory C:\\Temp\\ that begin with "vcm" and
	 export those files to file All-VCM.csv in the same directory.
	 
	.Example
	 
	 Combine-CSV -SourceFolder "C:\\Temp\\" -Filter "vcm*.csv"
	 
	 This will combine all .CSVs that start with "vcm" and output results to screen only
	 since the -ExportFileName parameter is not used.
	 
	.Link
	 http://www.vtesseract.com
	 
	.Notes
	====================================================================
	Author(s):		
	Josh Atwell <josh.c.atwell@gmail.com> http://www.vtesseract.com/
					
	Date:			2012-10-02
	Revision: 		1.0

	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
		
#>
param(
	[Parameter(Position=0,Mandatory=$true,HelpMessage="Please provide the folder which contains your .CSV files.")]
	$SourceFolder,
	[Parameter(Position=1,Mandatory=$false,HelpMessage="Please provide any Get-ChildItem filter you would like to apply")]
	[String]$Filter,
	[Parameter(Position=2,Mandatory=$false,HelpMessage="Please provide exported CSV filename")]
	[String]$ExportFileName
	)

Begin{
If ($SourceFolder.EndsWith("\\") -eq $false){
	$SourceFolder = $SourceFolder + "\\"
}
Write-Verbose "Source Folder is $SourceFolder"
If ((Test-Path $SourceFolder) -eq $True){
	$files = Get-childitem -Path $SourceFolder -Filter $Filter | Sort
	$count = ($files).Count
	Write-Verbose "Combining $count .CSV files"
	$FullText = Get-Content ($files | Select -First 1).FullName
}Else{
	Write-Output "Path $SourceFolder does not exist"
}
}
Process{
	foreach($file in ($files | Select -Skip 1)){
		$FullText = $FullText + (Get-Content $file.FullName | Select -Skip 1)
	}
}
End{
	If($ExportFileName -ne ""){
		$DestinationFullPath = $SourceFolder + $ExportFileName
		Write-Verbose "Writing output to file $DestinationFullPath"
		Set-Content -Path $DestinationFullPath -Value ($FullText)
	} Else {
	return $FullText
	}
}
}
