function Start-Story {
	if(CheckGitConfig) {
		CheckPivotalConfig
		ListLastFiveHistories
	}
}

function Stop-Story {
	$currentBranch = Invoke-Expression 'git rev-parse --abbrev-ref HEAD 2>$null'
	$storyId = GetStoryIdFromBranch($currentBranch)
	if((CheckGitConfig) -and ($storyId -ne '')) {
		CheckPivotalConfig
		git checkout master
		git merge $currentBranch
		$endpoint = ("/stories/{0}" -f $storyId)
		PutData $endpoint "{`"current_state`":`"finished`"}"
        git branch -d $currentBranch
	}
}

function ListLastFiveHistories {
	Write-Host 'Getting you stories...'
	$stories = GetData "/stories?limit=5&with_state=unstarted"
	Foreach ($story in $stories) {
		Write-Host ("[{0}] {1} - {2}" -f $story.story_type, $story.id, $story.name) 
	}
	Write-Host ""
	$selectedHistoryId = Read-Host "Please tell me the history id that you want to start working"
	CreateFeatureBranch $selectedHistoryId
}

function CreateFeatureBranch($selectedHistoryId) {
	$endpoint = ("/stories/{0}" -f $selectedHistoryId)
	$story = GetData $endpoint
	$storyType = $story.story_type
	Write-Host ("Creating your new {0} branch" -f $storyType)
	git checkout -b ("{0}-{1}" -f $storyType, $story.id)
	PutData $endpoint "{`"current_state`":`"started`"}"
}

function PutData($endpoint, $data) {
	$webClient = GetWebClient
	$url = GetUrl $endpoint
	$data = $webClient.UploadString($url, 'PUT', $data)
    return $data | ConvertFrom-Json
}

function GetData($endpoint) {
	$webClient = GetWebClient
	$url = GetUrl $endpoint
	$data = $webClient.DownloadString($url)
	return $data | ConvertFrom-Json
}

function GetUrl($endpoint) {
	$baseUrl = GetBaseUrl
	return ("{0}{1}" -f $baseUrl, $endpoint)
}

function GetBaseUrl() {
	$pivotalProjectId = Invoke-Expression 'git config --get pivotal.project-id 2>$null'
	return ("https://www.pivotaltracker.com/services/v5/projects/{0}" -f $pivotalProjectId)
}

function GetWebClient($endpoint) {
	$pivotalApiToken = Invoke-Expression 'git config --get pivotal.api-token 2>$null'
	$webClient = new-object System.Net.WebClient
	$webClient.headers.Add('X-TrackerToken', $pivotalApiToken)
	$webClient.headers.Add('Content-Type', 'application/json')
	return $webClient
}

function CheckGitConfig {
	if(-not (Test-Path '.git')) {
		Write-Host "You need to be inside a git repository"
		return $false
	} else {
		return $true
	}
}

function CheckPivotalConfig() {
	$pivotalApiToken = Invoke-Expression 'git config --get pivotal.api-token 2>$null'
	if($pivotalApiToken -eq $null) {
		$pivotalApiToken = Read-Host "You need to set your Pivotal Tacker API Token, please inform it here"
		git config --global pivotal.api-token $pivotalApiToken
	}

	$pivotalFullName = Invoke-Expression 'git config --get pivotal.full-name 2>$null'
	if($pivotalFullName -eq $null) {
		$pivotalFullName = Read-Host "You need to set your Pivotal Tacker Name, please inform it here"
		git config --global pivotal.full-name $pivotalFullName
	}

	$pivotalProjectId = Invoke-Expression 'git config --get pivotal.project-id 2>$null'
	if($pivotalProjectId -eq $null) {
		$pivotalProjectId = Read-Host "You need to set your Pivotal Project Id, please inform it here"
		git config -f .git/config pivotal.project-id $pivotalProjectId
	}
}

function GetStoryIdFromBranch($currentBranch) {
    Write-Host $currentBranch
	if($currentBranch -match '(feature|bug|chore)-(?<storyId>[0-9].+)') {
		return $matches['storyId']
	} else {
		Write-Host "You need to be inside a story branch to finish a story"
		return ''
	}
}

Export-ModuleMember *-*