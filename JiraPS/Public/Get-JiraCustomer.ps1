function Get-JiraCustomer {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('Query')]
        [String[]]
        $Querystring,

        [Parameter()]
        [Alias('ProjectKey')]
        [String]
        $Project,

        [Parameter()]
        [ValidateRange(1, 1000)]
        [UInt32]
        $limit = 50,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [uint32]
        $start = 0,

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
        $Uri = "$server/rest/servicedeskapi/servicedesk/$($SDObj.id)/customer?query={0}"

        if(!$Credential -and !(Get-JiraSession)){Throw "No credentials provided and no active session found."}
        elseif(!(Get-JiraSession)){
            Write-Verbose "No active session found. Creating a new session..."
            New-JiraSession -Credential $Credential
        }

        # Append additional parameters if specified
        if ($limit) {
            $Uri += "&limit=$limit"
        }
        if ($start) {
            $Uri += "&start=$start"
        }

    }

    process {
        Write-Verbose "Getting customer information from Jira..."



    # Invoke API to retrieve user information
    foreach ($q in $Querystring) {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing Query [$q]"
        $headers = @{"Accept" = "application/json"
                    "X-ExperimentalApi" = "opt-in"}

        $response = Invoke-RestMethod -Uri ($Uri -f $q) -Headers $headers -Method Get -WebSession $(Get-JiraSession).WebSession
        if($response.isLastPage -eq $false){Throw "The response is paged. This function does not support paged responses."}
        $response.values
    }
    }
    end {
        Write-Verbose "Jira customer retrieval complete."
    }
}
