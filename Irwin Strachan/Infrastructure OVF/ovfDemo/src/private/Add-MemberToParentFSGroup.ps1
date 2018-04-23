Function Add-MemberToParentFSGroup{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $GroupMember
    )

    process {
        foreach ($member in $GroupMember) {
            switch -Wildcard ($member) {
                'FS*FULL'{
                    Write-Verbose "Adding group $member to 'FS FULL'"
                    Add-ADGroupMember -Identity 'FS FULL' -Members $member
                }
                'FS*NONE'{
                    Write-Verbose "Adding group $member to 'FS NONE'"
                    Add-ADGroupMember -Identity 'FS NONE' -Members $member
                }
                'FS*READ'{
                    Write-Verbose "Adding group $member to 'FS READ'"
                    Add-ADGroupMember -Identity 'FS READ' -Members $member
                }
                'FS*LIST'{
                    Write-Verbose "Adding group $member to 'FS LIST'"
                    Add-ADGroupMember -Identity 'FS LIST' -Members $member
                }
            }
        }
    }
}