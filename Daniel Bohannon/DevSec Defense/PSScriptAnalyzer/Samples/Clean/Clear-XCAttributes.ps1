param(
[Parameter(Position=0,ValueFromPipeline=$True)]
[ValidateNotNullorEmpty()] $User,
[switch]$ClearXCAttributes
)

begin{
$Global:LegacyXCUsers = @()
# attributes to be nulled according to:
# http://blogs.technet.com/b/exchange/archive/2006/10/13/3395089.aspx
$XCattributes=@(
"adminDisplayName","altRecipient","authOrig","autoReplyMessage","deletedItemFlags","delivContLength","deliverAndRedirect","displayNamePrintable",
"dLMemDefault","dLMemRejectPerms","dLMemSubmitPerms","extensionAttribute1","extensionAttribute10","extensionAttribute11","extensionAttribute12",
"extensionAttribute13","extensionAttribute14","extensionAttribute15","extensionAttribute2","extensionAttribute3","extensionAttribute4","extensionAttribute5",
"extensionAttribute6","extensionAttribute7","extensionAttribute8","extensionAttribute9","folderPathname","garbageCollPeriod","homeMDB","homeMTA",
"internetEncoding","legacyExchangeDN","mail","mailNickname","mAPIRecipient","mDBOverHardQuotaLimit","mDBOverQuotaLimit","mDBStorageQuota","mDBUseDefaults",
"msExchADCGlobalNames","msExchControllingZone","msExchExpansionServerName","msExchFBURL","msExchHideFromAddressLists","msExchHomeServerName",
"msExchMailboxGuid","msExchMailboxSecurityDescriptor","msExchPoliciesExcluded","msExchPoliciesIncluded","msExchRecipLimit","msExchResourceGUID",
"protocolSettings","proxyAddresses","publicDelegates","securityProtocol","showInAddressBook","submissionContLength","targetAddress","textEncodedORAddress",
"unauthOrig"
)
}

process{
$Global:LegacyXCUsers += (get-aduser -Identity $User -Properties *)
if ($ClearXCAttributes){
	write-verbose "all XC attributes will be cleared for $user"
	set-aduser -Identity $User -Clear $XCattributes
	}
	
}

end{
$Global:LegacyXCUsers 
}
