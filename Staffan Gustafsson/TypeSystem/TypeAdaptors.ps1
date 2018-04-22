# Load my custom adapter, derived from PSPropertyAdapter
Import-Module $demohome\.demo\BuildProjectAdapter.dll
# Direct convertion from a string! How?
[proj] $proj = "$demohome\CppProj\CppGame.vcxproj"
$proj

# Here is the view of all items, not just the special once we have filtered
$proj.ProjectItems

# Use what we know about ETS to make it look better
# Update typedata for common types
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectItem -DefaultDisplayPropertySet ItemType, MetaDataCount, EvaluatedInclude -Force
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectItem -DefaultDisplayProperty EvaluatedInclude -Force
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectItem -MemberType ScriptMethod -MemberName ToString -Value {$this.EvaluatedInclude}
# Update typedata for common types
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectMetadata -DefaultDisplayPropertySet Name, ItemType, UnevaluatedValue, EvaluatedValue -Force
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectMetadata -DefaultDisplayProperty Name  -Force
Update-TypeData -typename Microsoft.Build.Evaluation.ProjectMetadata -MemberType ScriptMethod -MemberName ToString -Value {$this.Name}

$proj.ProjectItems

$proj.ImportedProjects

$proj.ProjectItems.ClCompile