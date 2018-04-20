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

.DESCRIPTION
Similar in vein to Add-EventLogs to MongoDB. http://poshcode.org/3586
The script takes about 100 counter paths, and pushes the raw value to a mongo database.
Script can be modified to add CookedValue instead of Raw Value.
TimeStamps are in UTC -4 (EDT)
You can watch the events using MongoVue
http://www.mongovue.com/

Script needs some clean-up to accept input from pipeline for computername, counter names etc.
.STATUS 
Alpha - FASTPUBLISH

.TODO
a) Check if script can accept -continious

#>

$mongoDriverPath = 'C:\\Program Files (x86)\\MongoDB\\CSharpDriver 1.5'
Add-Type -Path "$($mongoDriverPath)\\MongoDB.Bson.dll";
Add-Type -Path "$($mongoDriverPath)\\MongoDB.Driver.dll";

$db = [MongoDB.Driver.MongoDatabase]::Create('mongodb://localhost/eventsX');
$collection = $db['counters'];

$counters= "memory", "processor", "logicaldisk", "physicaldisk"
$paths = (get-counter -List $counters).paths 

#About 100 counter paths covering all memory, processor, logicaldisk and physical disk
$samples = (get-counter -Counter $paths).CounterSamples

foreach ($i in $samples) {

[MongoDB.Bson.BsonDocument] $doc = @{
    "_id"= [MongoDB.Bson.ObjectId]::GenerateNewId();
    "Time"= $i.TimeBase;
    "Counters"= [MongoDB.Bson.BsonDocument] [ordered] @{
        "Path"= $i.Path;
        "RawValue"= $i.RawValue;
        #EDT compensate UTC -4 hrs in minutes (-240)
        "TimeStamp"= ($i.Timestamp).AddMinutes(-240);
        "TimeStamp100nsec"= $i.Timestamp100NSec;
        }; #End of Counters
    }; #End of $doc

$collection.Insert($doc);
} #End of ForEach

