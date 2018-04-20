<#
.SYNOPSIS
  Compares two result sets from SQL queries for differences.
.DESCRIPTION
  Compares the result sets from two SQL queries and outputs the
  differences.
  
  Currently the function only handles similarly shaped result sets. That is,
  result sets with the same number and names of columns. Functionality will be
  added in the future to allow for comparison and differencing of disparate result
  sets.
.PARAMETER ServerName1
  The name of the server on which the first query should be executed.
.PARAMETER DatabaseName1
  The name of the database on which the first query should be executed.
.PARAMETER Query1
  The first SQL query to be executed.
.PARAMETER ServerName2
  The name of the server on which the second query should be executed.
.PARAMETER DatabaseName2
  The name of the database on which the second query should be executed.
.PARAMETER Query2
  The second SQL query to be executed.
.EXAMPLE
  Compare-SQLResultSet -ServerName1 myServer1 -DatabaseName1 myDatabase -Query1 "exec dbo.myproc" -ServerName2 myServer2 -DatabaseName2 myDatabase -Query2 "exec dbo.myproc_changed"

  Could be used to compare two result sets from the same server and database, but two different
  procedures. Useful for comparing old and new code.
.NOTES
  Author: Josh Feierman
  Version: 1

#>
function Compare-SQLResultSet
{
  [Cmdletbinding()]
  param
  (
      [parameter(mandatory=$true)]
      [String]$ServerName1,
      [parameter(mandatory=$true)]
      [String]$DatabaseName1,
      [parameter(mandatory=$true)]
      [String]$Query1,
      [parameter(mandatory=$true)]
      [String]$ServerName2,
      [parameter(mandatory=$true)]
      [String]$DatabaseName2,
      [parameter(mandatory=$true)]
      [String]$Query2
  )
  try
  {
      if (-not (Get-Module -Name SQLPS -ListAvailable))
      {
          Write-Warning "The SQLPS module is not installed, please obtain and install it."
          return
      }
      Import-Module SQLPS
  
      #Get the two result sets
      $resultSet1 = Invoke-Sqlcmd -ServerInstance $ServerName1 -Database $DatabaseName1 -Query $Query1
      $resultSet2 = Invoke-Sqlcmd -ServerInstance $ServerName2 -Database $DatabaseName2 -Query $Query2
  
      #Get a count of records in both sets, so we can iterate over the correct number
      $firstCount = $resultSet1.Count
      $secondCount = $resultSet2.Count
  
      if ($firstCount -gt $secondCount) {$totalCount = $firstCount}
      elseif ($secondCount -gt $firstCount) {$totalCount = $secondCount}
      else {$totalCount = $firstCount}
  
      #Begin iteration
      for ($counter = 0; $counter -lt $totalCount; $counter ++)
      {
          #Get the row from the first result set
          if ($counter -lt $firstCount)
          {
              $firstRow = $resultSet1[$counter]
          }
          else
          {
              $firstRow = $null
          }
          if ($counter -lt $secondCount)
          {
              $secondRow = $resultSet2[$counter]
          }
          else
          {
              $secondRow = $null
          }
  
          #Create custom output object for comparison
          $compareObject = New-Object PSObject -Property @{
              RowNumber = $counter + 1
              ColumnName = $null
              FirstValue = $null
              SecondValue = $null
          }
  
          #Get a list of columns
          $properties = Get-Member -inputObject $firstRow -MemberType Properties
  
          foreach ($property in $properties)
          {
              $firstValue = $firstRow.Item($property.Name)
              $secondValue = $secondRow.Item($property.Name)
  
              if ($firstValue -ne $secondValue)
              {
                  $compareObject.ColumnName = $property.Name
                  $compareObject.FirstValue = $firstValue
                  $compareObject.SecondValue = $secondValue
  
                  Write-Output $compareObject
              }
          }
      }
  }
  catch
  {
      Write-Warning $_.Exception.Message
  }

}
