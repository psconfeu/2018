<#
.NOTES
AUTHOR: Sunny Chakraborty(sunnyc7@gmail.com)
WEBSITE: http://tekout.wordpress.com
CREATED: 8/20/2012
Requires: 
a) PowerShell v2 or better
b) Requires Mongo Official C# driver
https://github.com/mongodb/mongo-csharp-driver/downloads
Tested using 1.5.0.X
c) Thanks to Justin Dearing for this: 
https://gist.github.com/854911
blog post- http://www.justaprogrammer.net/2012/04/19/powershell-3-0-ordered-and-mongodb/
The reg lookup to find mongo install path doesnt work in v1.5.x of C# Driver

.DESCRIPTION
Insert event logs in mongodB.

You can watch the events using MongoVue
http://www.mongovue.com/

#>

$mongoDriverPath = 'C:\\Program Files (x86)\\MongoDB\\CSharpDriver 1.5'
Add-Type -Path "$($mongoDriverPath)\\MongoDB.Bson.dll";
Add-Type -Path "$($mongoDriverPath)\\MongoDB.Driver.dll";

$db = [MongoDB.Driver.MongoDatabase]::Create('mongodb://localhost/eventmonitor');
$collection = $db['events'];

# I just grabbed first 10 from Application. Feel free to filter using Error/Warning etc.
$events = get-eventlog Application -newest 10

for ($i = 0; $i -le $events.Count-1; $i++) {

# I am not sure why, but I had to use these temp variables to insert documents into mongodB as JSON
# without temp variables, the rows were getting inserted as System.Diagnostic.EventLogEntry. I know it looks kinda uncool.
# please suggest better options

$a = $events[$i].Index
$b= $events[$i].EntryType
$c= $events[$i].InstanceID
$d= $events[$i].Category
$e= $events[$i].ReplacementStrings
$f= $events[$i].Source
$g= $events[$i].TimeGenerated
$h= $events[$i].EventID
$msg = $events[$i].Message

[MongoDB.Bson.BsonDocument] $doc = @{
    "_id"= [MongoDB.Bson.ObjectId]::GenerateNewId();
    "Index"= "$a";
    "EntryType"= "$b";
    "InstanceID"= "$c";
    "Category"= "$d";
    "ReplacementStrings"= "$e";
    "Source"= "$f";
    "TimeGenerated"= "$g";
    "EventID"= "$h";
    "Message"= "$msg";
    };

$collection.Insert($doc);
}

