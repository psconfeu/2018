# Let's ask powershell about this Update-TypeData thing
Get-Command -Syntax Update-TypeData

# Some sample data from issue tracking domain
# Type is "IssueTracking" and it has a "Description" property
$objs = . {
  [PSCustomObject] @{ PSTypeName="IssueTracking"; ID = 1; Owner = "Staffan"; Description = "I really messed up. JIRA-6547 explains exactly how badly!"}
  [PSCustomObject] @{ PSTypeName="IssueTracking"; ID = 2; Owner = "Staffan"; Description = "When trying to fix an issue in JIRA-6547, I made things worse. JIRA-6549 tries to explain!"}
  [PSCustomObject] @{ PSTypeName="IssueTracking"; ID = 3; Owner = "Staffan"; Description = "I updated a jira,  JIRA-6547, where I try to gather the reasons why you sholdn't fire me"}
  [PSCustomObject] @{ PSTypeName="IssueTracking"; ID = 4; Owner = "Staffan"; Description = "I shouldn't have opened that last Jira! HR are now involved :("}
}
$objs

# Add a "Jira" property that uses regex to find jira references in the text
$updateTypeDataParams = @{
  TypeName = "IssueTracking"
  MemberType = "ScriptProperty"
  MemberName = "Jira"
  Value = { [string[]][regex]::Matches($this.Description, "JIRA-\d{2,}").Value }
}
Update-TypeData @updateTypeDataParams -Force

# And we can see that it now has a jira property
$objs | Format-Table -AutoSize ID, Owner, Jira, Description

# To get back the original look, update the DefaultDisplayPropertySet
Update-TypeData -TypeName IssueTracking -DefaultDisplayPropertySet Id, Owner, Description -Force
$objs

# But it is still easy to group on Jiras
$objs | Group-Object Jira

# And the Group output was not helpful. Add ToString
$updateTypeDataParams = @{
  TypeName = "IssueTracking"
  MemberType = "ScriptMethod"
  MemberName = "ToString"
  Value = { "Issue $($this.Id)" }
}
Update-TypeData @updateTypeDataParams -Force

# Now, when we group on Jira
$objs | Group-Object Jira

# Here are the members
$objs | Get-Member

# Clear the type data from IssueTracking
Remove-TypeData -TypeName IssueTracking
$objs | Get-Member

# As an alternative, here is a class that does the same thing
# Here I'm using the programatic way of working with the TypeData
class Issue {
  [int]    $Id
  [string] $Owner
  [string] $Description

  [string] ToString() {return "Issue $($this.Id)"}

  hidden static [string[]] GetJiraProperty([psobject] $obj) {
    return [regex]::Matches($obj.Description, "JIRA-\d{2,}").Value
  }

  static Issue() {
    $m = [Issue].GetMethod("GetJiraProperty")
    $jiraPropertyData= [System.Management.Automation.Runspaces.TypeData]::new("Issue")
    $codeProperty = [System.Management.Automation.Runspaces.CodePropertyData]::new("Jira", $m, $null)
    $jiraPropertyData.Members.Add("Jira", $codeProperty)
    Update-TypeData -TypeData $jiraPropertyData -Force
  }
}


# And convert our objects to Issues
# This works as they have the same set of members
[Issue[]] $issues = $objs
$issues

# Group output should look OK
$issues | Group-Object Jira

# and to verify the types
$issues | Get-Member

# Back to presentation
Invoke-Item $demohome\Typesystem.pptx
exit


