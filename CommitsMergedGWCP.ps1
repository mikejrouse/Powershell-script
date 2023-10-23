#####################
#
# setup:
# 1. create directory c:/bitbucket/
# 2. Copy script.ps1 to c:/bitbucket
# 3. set the variable values for
#	 $bitbucketUsername
#	 $bitbucketPassword
# 4. Confirm the repo variable values and the Personal Access Bearer token and API url
#	 $bitbucketApiUrl
#        $bitbucketBearerToken
#	 $bcRepoName
#	 $ccRepoName 
#	 $pcRepoName
#        $cmRepoName
#        $choice
# 4. run c:/bitbucket/CommitsMergedV1.0.ps1
#    Report .csv is saved to c:/bitbucket/report.csv
#
# reference - powershell and APIs - https://pallabpain.wordpress.com/2016/09/14/rest-api-call-with-basic-authentication-in-powershell/
# reference - Office 365 not up to date - https://docs.microsoft.com/en-us/archive/blogs/webdav_101/invoke-restmethod-the-underlying-connection-was-closed-an-unexpected-error-occurred-on-a-send-while-using-powershell
# reference - powershell and JSON - https://www.business.com/articles/using-powershell-with-json-data/
# $bitbucketApiUrl = "https://bitbucket.emcdev.guidewire.net/rest/api/1.0/projects/IS/repos/"
# 
#####################
$bitbucketBearerToken = "asdf"
$bitbucketApiUrl = "https://bitbucket.emc.dev-1.us-east-1.guidewire.net/rest/api/1.0/projects/CORECON/repos/"
$reportFile="c:/bitbucket/report.csv" ##report file location

$bcRepoName="BillingCenter"
$ccRepoName="ClaimCenter"
$pcRepoName="PolicyCenter"
$cmRepoName="ContactManager"
# $choice="4"

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
		
			Add-Content -Path $reportFile -Value "$aRepoName,$aDisplayName $anEmailAddress,""$aMessage"",$aCommittedDateTime"
		}
	}
}
#clear
Set-Content -Path $reportFile -Value 'Repository,Author,Commit,Commit Date'



$choice = Read-Host -Prompt 'Deploy details for (1) BC, (2) CC, (3) PC, or (4) ALL? Press 1,2,3,4'

#echo "Deploy details for (1) BC, (2) CC, (3) PC, or (4) ALL? Press 1,2,3,4"
#$key = [System.Console]::ReadKey()
#$choice = $key.Key.ToString()
#echo
#echo $choice
#pause

if ($choice -eq "1" -Or $choice -eq "4") {Run-Repo-Report $bcRepoName}
if ($choice -eq 2 -Or $choice -eq 4) {Run-Repo-Report $ccRepoName}
if ($choice -eq 3 -Or $choice -eq 4) {Run-Repo-Report $pcRepoName}
if ($choice -eq 4) {Run-Repo-Report $cmRepoName}

pause
