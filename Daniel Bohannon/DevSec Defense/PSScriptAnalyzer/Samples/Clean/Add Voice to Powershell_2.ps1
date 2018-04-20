###
# Description: Add Voice to Powershell
# Version: 1.1 (11 Nov 2008)
# Mike Hays / www.mike-hays.net / blog.mike-hays.net
# Virtualization, Powershell, and more...
###

# This is the actual speaking part.  I cheat by adding spaces
# (This makes the word sound right).
$spokenText = "Super ca li fragilistic expi alidocious"

# Create an object that represents the COM SAPI.SpVoice
$voice = New-Object -com SAPI.SpVoice

# Get the list of available voices
$voiceList = $voice.GetVoices()

# This script prefers using LH Michelle as a stand-in for Mary Poppins,
# but I can't be sure that she exists on all computers, so I check for that.
# She comes with some installations of Microsoft Word 2003.
$voiceDescList = @()
for ($i=0; $i -lt $voiceList.Count; $i++)
{
    $voiceDescList += $voiceList.Item($i).GetDescription()
}

if ($voiceDescList -contains "LH Michelle")
{
    $voiceMember = "Name=LH Michelle"
}
else
{
    # This is the default voice if LH Michelle doesn't exist.
    # This will probably be Microsoft Sam
    $voiceMember = "Name=" + $voiceDescList[0]
}
$voiceToUse = $voice.GetVoices($voiceMember)

# This sets the voice property on the COM object
$voice.Voice = $voiceToUse.Item(0)

# This actually does the speaking.
[void] $voice.Speak($spokenText)

# She's no Julie Andrews, but she'll say what you want.
# END
