#####################
#
# setup:
# 1. create directory c:/bitbucket/
# 2. Copy script.ps1 to c:/bitbucket
# 3. set the variable values for
# $bitbucketUsername
# $bitbucketPassword
# 4. Confirm the repo variable values and the Personal Access Bearer token and API url
# $bitbucketApiUrl
# $bitbucketBearerToken
# $bcRepoName
# $ccRepoName 
# $pcRepoName
# $cmRepoName
# $choice
# 4. run c:/bitbucket/CommitsMergedV1.0.ps1
# Report .csv is saved to c:/bitbucket/report.csv
#
# reference - powershell and APIs - https://pallabpain.wordpress.com/2016/09/14/rest-api-call-with-basic-authentication-in-powershell/
# reference - Office 365 not up to date - https://docs.microsoft.com/en-us/archive/blogs/webdav_101/invoke-restmethod-the-underlying-connection-was-closed-an-unexpected-error-occurred-on-a-send-while-using-powershell
# reference - powershell and JSON - https://www.business.com/articles/using-powershell-with-json-data/
# $bitbucketApiUrl = "https://bitbucket.emcdev.guidewire.net/rest/api/1.0/projects/IS/repos/"
# 
#####################
#Requires -Modules @{ModuleName='AWS.Tools.S3';ModuleVersion='4.0.6.0'}
#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.6.0'}
#Requires -Modules @{ModuleName='AWS.Tools.EC2';ModuleVersion='4.0.6.0'}
#Requires -Modules @{ModuleName='AWS.Tools.SimpleSystemsManagement';ModuleVersion='4.0.6.0'}

$bitbucketBearerToken = (Get-SSMParameterValue -Name /itdev/scheduledcommits/bearertoken -WithDecryption 1).Parameters.Value

$bitbucketApiUrl = "https://bitbucket.emc.dev-1.us-east-1.guidewire.net/rest/api/1.0/projects/CORECON/repos/"


$bcRepoName="BillingCenter"
$ccRepoName="ClaimCenter"
$pcRepoName="PolicyCenter"
$cmRepoName="ContactManager"
$choice="4"


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-API-Call([string]$url) {

# Step 1. Form the authorization header and add the bearer details to it
$headers = @{ Authorization = "Bearer $bitbucketBearerToken" }

# Step 2. Make the GET request
$responseData = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -UseBasicParsing
return $responseData
}

function Convert-To-Date-String([string]$aMillisecondString) {
$aTimeSpan = [TimeSpan]::FromMilliseconds([double]$aMillisecondString)
$aConvertedDate = [DateTime]::new(1970, 1, 1) + $aTimeSpan

$aConvertedDate = $aConvertedDate.ToLocalTime()

#return $aConvertedDate.ToString("R") #Tue, 10 Dec 2019 18:12:13 GMT

return $aConvertedDate.ToString("ddd MMM d HH:mm:ss yyyy") #Tue Dec 10 18:12:13 2019
}


function Run-Repo-Report([string]$aRepoName) {
$aRepoCommitsUrl = "$bitbucketApiUrl$aRepoName/commits/"

#echo "############################"
#echo $aRepoCommitsUrl
#echo "############################"


$aResponse = Get-API-Call $aRepoCommitsUrl

#echo "############################"
#echo "after call"
#echo $aResponse > debug.txt
#echo "############################"
#pause

$aResponseObject = $aResponse | ConvertFrom-Json

#echo "############################"
#echo $aResponseObject
#echo "############################"
#pause

#echo $aResponseObject.values[0]
#echo "############################"
#pause



foreach ($aValue in $aResponseObject.values) {
if ($aValue.message | Select-String -pattern "Merge.*to develop" -quiet) {
$aMessage = $aValue.message -replace "`n|`r"
$aDisplayName = $aValue.author.displayName
$anEmailAddress = $aValue.author.emailAddress
$aTimeInMilliseconds = $aValue.committerTimestamp
$aCommittedDateTime = (Convert-To-Date-String $aTimeInMilliseconds)

#Add-Content -Path $reportFile -Value "$aRepoName,$aDisplayName $anEmailAddress,""$aMessage"",$aCommittedDateTime"
$OutputString += "<tr><td>$aRepoName</td><td>$aDisplayName $anEmailAddress</td><td>""$aMessage""</td><td>$aCommittedDateTime</td></tr>"
}
}
return $OutputString
}




#
# write the current days info
#
$OutputString +="<html>"
$OutputString +="<head>"
$OutputString +=' <link href="https://cdn.dev.emcins.com/css/emc.css" rel="stylesheet">'
$OutputString +=" <style>"
$OutputString +="#commits {"
$OutputString +=' font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;'
$OutputString +=" border-collapse: collapse;"
$OutputString +=" width: 100%;"
$OutputString +="}"
$OutputString +="#commits td, #commits th {"
$OutputString +=" border: 1px solid #ddd;"
$OutputString +=" padding: 8px;"
$OutputString +="}"
$OutputString +="#commits tr:nth-child(even){background-color: #f2f2f2;}
$OutputString +="#commits tr:hover {background-color: #ddd;}"
$OutputString +="#commits th {"
$OutputString +=" padding-top: 12px;"
$OutputString +=" padding-bottom: 12px;"
$OutputString +=" text-align: left;"
$OutputString +=" background-color: #4CAF50;"
$OutputString +=" color: white;"
$OutputString +="}"
$OutputString +="</style>"
$OutputString +="</head>"
$OutputString +='<body style="margin: 0;font-family: Roboto,Helvetica Neue,sans-serif;">'
$OutputString +='<nav style="background: #0082c8;height: 60px;z-index: 1040;top: 0;border-width: 0 0 1px;"><div class="container-fluid"><div class="navbar-header">'
$OutputString +='<a href="#" style="float: left; height: 50px;padding: 15px; font-size: 18px;line-height: 20px;"><img src="https://cdn.dev.emcins.com/img/emc-logo-white.png" style=" max-height: 36px;"></a></div></div></nav>'
$OutputString += '<table id="commits" style="width:95%;margin-left:auto;margin-right:auto"><tr><td><b>Repository</b></td><td><b>Author</b></td><td><b>Commit</b></td><td><b>Commit Date</b></td></tr>'
$OutputString += Run-Repo-Report $bcRepoName
$OutputString += Run-Repo-Report $ccRepoName
$OutputString += Run-Repo-Report $pcRepoName
$OutputString += Run-Repo-Report $cmRepoName
$OutputString += "</table>"
$OutputString += "</body>"
$OutputString += "</html>"
$today = Get-Date -Format "MM-dd-yyyy"
$DayOfWeek = Get-Date -Format "dddd"
write-s3object emc.ins.itdev.use1.scheduledcommits -key index.html -content $OutputString -Metadata @{"Cache-Control" = "no-cache;max-age=0"} -HeaderCollection @{"Cache-Control" = "no-cache;max-age=0"}
