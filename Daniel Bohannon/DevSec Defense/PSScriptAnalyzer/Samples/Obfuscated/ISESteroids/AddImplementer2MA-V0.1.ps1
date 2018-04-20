ipmo smlets
${/====\__/===\_/\_} = 'MA121'
${_/=\_/\/=\__/\/=\} = "Peter Pan"
${_/\/\____/\/===\_} = Get-SCSMClass -Name  System.WorkItem.Activity.ManualActivity$
${/=\/\/\/\/==\/\__} = Get-SCSMObject -Class ${_/\/\____/\/===\_} -Filter $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SQBEACAALQBlAHEAIAAkAHsALwA9AD0APQA9AFwAXwBfAC8APQA9AD0AXABfAC8AXABfAH0A')))
${/=\_/=\/=====\/=\} = Get-SCSMClass -Name Microsoft.AD.User$
${/====\______/==\_} = Get-SCSMObject -Class ${/=\_/=\/=====\/=\} –Filter $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABpAHMAcABsAGEAeQBOAGEAbQBlACAALQBlAHEAIAAkAHsAXwAvAD0AXABfAC8AXAAvAD0AXABfAF8ALwBcAC8APQBcAH0A')))
${/=\_/=\______/\/\} = Get-SCSMRelationshipClass -Name System.WorkItemAssignedToUser$
New-SCSMRelationshipObject -RelationShip ${/=\_/=\______/\/\} -Source ${/=\/\/\/\/==\/\__} -Target ${/====\______/==\_} -Bulk
rmo smlets -Force