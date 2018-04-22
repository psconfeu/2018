<#
.SYNOPSIS
Just a simple function to get the face attributes from the Microsoft Cognitive Services

.DESCRIPTION
Just a simple function to get the face attributes from the Microsoft Cognitive Services

.EXAMPLE
Get-SpeakerFace

Gets the speaker faces and analyses them with API

.NOTES
General notes
#>
Function Get-SpeakerFace {
    ## Grab the webpage
    try {
        $Webpage = Invoke-WebRequest http://tugait.pt/2017/speakers/       
    }
    catch {
        Write-warning "Failed to get tugaait page"
        break
    }
    
    ## Process the images with the  api
    $webpage.Images.Where{$_.class -eq 'speaker-image lazyOwl wp-post-image'}.src | ForEach-Object {
        $jsonBody = @{url = $_} | ConvertTo-Json
        $apiUrl = "https://westeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
        $apiKey = $Env:MS_Faces_Key
        $headers = @{ "Ocp-Apim-Subscription-Key" = $apiKey }
        $analyticsResults = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $jsonBody -ContentType "application/json"  -ErrorAction Stop
        [pscustomobject]@{
            Name           = $_ -replace '.*\/(.*)\..*$', '$1' -replace '-|(\d{3}x\d{3})'
            FaceAttributes = $analyticsResults.FaceAttributes
            ImageUrl       = $_
        }
        # Start-Sleep -Seconds 4 ## need the sleep to keep inside the free api rate  limits
    } 
}
