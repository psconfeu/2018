
<#
.SYNOPSIS
Gets the Speaker Beard Ranking from the TUGAIT website

.DESCRIPTION
Analyses the Speaker pictures ont eh TUGAIT website with Microsoft Cognitive Services
and returns the analysis. Also returns the top and bottom ranked beards

.PARAMETER Speaker
The Speaker Name 

.PARAMETER Webpage
If not provided - the webpage of the Speakers

.PARAMETER Faces
A JSON object containing the image URLs fromt eh TUGAIT website

.PARAMETER Detailed
Returns the Speaker Name, Beard Ranking adn the URL of the picture

.PARAMETER ShowImage
A switch to open the URL in the default program

.PARAMETER Top
Returns the Top N speakers ranked by beard

.PARAMETER Bottom
Returns the Bottom N Speakers ranked by beard

.NOTES
Written for fun for TUGAIT
Rob Sewell 10/05/2017

.EXAMPLE 
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser 

Returns the beard ranking for JaapBrasser  using a Faces object returned from Get-SpeakerFace
	
.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -Detailed

Returns the Speaker name, beard ranking and URL of picture beard ranking for JaapBrasser
 using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -Detailed -ShowImage

Returns the Speaker name, beard ranking adn URL of picture beard ranking for JaapBrasser
and opens the URL of the image using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Top 5

Returns the top 5 speakers ranked by beard using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Bottom 5

Returns the bottom 5 speakers ranked by beard using a Faces object returned from Get-SpeakerFace
#>
 function Get-SpeakerBeard {
    param(
        $Speaker,
        $Faces ,
        [switch]$Detailed,
        [switch]$ShowImage,
        [int]$Top,
        [int]$Bottom
       )
   # If no faces grab some    
   if(!$Faces){
    $faces = (Get-SpeakerFace -webpage $Webpage)
   }
   # if no speaker tell them
   if(($Faces.Name -match $Speaker).count -eq 0) {
    Return "No Speaker with a name like that - You entered $($Speaker)"
   }
   else {
       if($Top -or $Bottom){
           if ($top) { 
               $Faces | Select-Object Name, @{
                   Name       = 'Beard'
                   Expression = {
                       [decimal]$_.faceattributes.facialhair.beard 
                   }
               } | Sort-Object Beard -Descending |Select-Object Name,Beard -First $top
           }
       
            if($bottom) { 
                $Faces|Select-Object Name, @{
               Name       = 'Beard'
               Expression = {
                   [decimal]$_.faceattributes.facialhair.beard 
               }
           } |Sort-Object Beard -Descending |Select-Object Name,Beard -Last $Bottom}
       }
       elseif(!($detailed)){
           $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
       }
       else {
           $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{
               Name       = 'Beard'
               Expression = {
                   [decimal]$_.faceattributes.facialhair.beard 
               }
           }, ImageURL
       }
       if($ShowImage){
           Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
       }
   }
}

