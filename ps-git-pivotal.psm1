function Start-Feature
{
	CheckPivotalConfig
	ListLastFiveHistories
}

function ListLastFiveHistories {
	
	$stories = GetData "stories?limit=5&with_state=unstarted"

	Foreach ($story in $stories) {
		Write-Host ("({0}) {1} - {2}" -f $story.story_type, $story.id, $story.name) 
	}
	Write-Host ""
}

function GetData($endpoint) {
	$pivotalApiToken = Invoke-Expression 'git config --get pivotal.api-token 2>$null'
	$pivotalProjectId = Invoke-Expression 'git config --get pivotal.project-id 2>$null'
	$url = ("https://www.pivotaltracker.com/services/v5/projects/{0}/{1}" -f $pivotalProjectId, $endpoint)
	$webClient = new-object System.Net.WebClient
	$webClient.headers.Add('X-TrackerToken', $pivotalApiToken)
	$data = $webClient.DownloadString($url)
	
	return $data | ConvertFrom-Json
}

function CheckPivotalConfig {
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

Export-ModuleMember *-*