function Get-JiraRequestType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [String[]]
        $RequestType,

        [Parameter()]
        [Alias('ProjectKey')]
        [String]
        $Project,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )



    begin {

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        # Get Jira server information
        $server = Get-JiraConfigServer -ErrorAction Stop

        Write-Verbose "Check for Project Key"
        $SDObj = Get-JiraServiceDesk -ProjectKey $Project

        # Construct URI based on parameters
        $Uri = "$server/rest/servicedeskapi/servicedesk/$($SDObj.id)/requesttype/"

        if(!$Credential -and !(Get-JiraSession)){Throw "No credentials provided and no active session found."}
        elseif(!(Get-JiraSession)){
            Write-Verbose "No active session found. Creating a new session..."
            New-JiraSession -Credential $Credential
        }
    }

    process {
        Write-Verbose "Getting customer information from Jira..."



        # Invoke API to retrieve user information
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Query [$requestType]"
        $headers = @{"Accept" = "application/json"
                    "X-ExperimentalApi" = "opt-in"}

        $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get -WebSession $(Get-JiraSession).WebSession
        if($response.isLastPage -eq $false){Throw "The response is paged. This function does not support paged responses."}
        if($RequestType){ $response.values | Where-Object { $_.name -in $RequestType }} else {$response.values}
    }
    end {
        Write-Verbose "Jira customer retrieval complete."
    }
}
