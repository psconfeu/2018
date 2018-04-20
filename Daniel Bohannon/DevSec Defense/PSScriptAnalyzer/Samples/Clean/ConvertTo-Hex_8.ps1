# Ported from C# technique found here: http://forums.asp.net/p/1298956/2529558.aspx
param ( [string]$SidString )

# Create SID .NET object using SID string provided
$sid = New-Object system.Security.Principal.SecurityIdentifier $sidstring

# Create a byte array of the proper length
$sidBytes = New-Object byte[] $sid.BinaryLength

#Convert to bytes
$sid.GetBinaryForm( $sidBytes, 0 )

# Iterate through bytes, converting each to the hexidecimal equivalent
$hexArr = $sidBytes | ForEach-Object { $_.ToString("X2") }

# Join the hex array into a single string for output
$hexArr -join ''
