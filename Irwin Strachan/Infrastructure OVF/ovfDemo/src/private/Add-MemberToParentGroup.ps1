Function Add-MemberToParentGroup {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $GroupMember,
        $CustomerCode
    )

    process {
        foreach ($member in $GroupMember) {
            switch -Wildcard ($member) {
                '*ADMINS' {
                    Write-Verbose "Adding group $member to 'PROXY ADMINS'"
                    Add-ADGroupMember -Identity 'PROXY ADMINS' -Members $member
                }
                "$($CustomerCode)*NONE" {
                    Write-Verbose "Adding group $member to 'PROXY NONE'"
                    Add-ADGroupMember -Identity 'PROXY NONE' -Members $member
                }
                '*PARTIAL' {
                    Write-Verbose "Adding group $member to 'PROXY PARTIAL'"
                    Add-ADGroupMember -Identity 'PROXY PARTIAL' -Members $member
                }
                '*Users' {
                    Write-Verbose "Adding group $member to 'PROXY Users'"
                    Add-ADGroupMember -Identity 'PROXY Users' -Members $member
                }
                'SVCADMINS*' {
                    Write-Verbose "Adding group $member to 'SERVICEADMINS Proxy'"
                    Add-ADGroupMember -Identity 'SERVICEADMINS Proxy' -Members $member
                }
            }
        }
    }
}