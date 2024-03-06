function Get-JiraServiceDesk {
    [CmdletBinding()]
    param(
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

        # Construct URI based on parameters
        $Uri = "$server/rest/servicedeskapi/servicedesk"

        if(!$Credential -and !(Get-JiraSession)){Throw "No credentials provided and no active session found."}
        elseif(!(Get-JiraSession)){
            Write-Verbose "No active session found. Creating a new session..."
            New-JiraSession -Credential $Credential
        }
    }

    process {
        $headers = @{"Accept" = "application/json"}
        Write-Verbose "Getting service desk information from Jira..."
        $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get -WebSession $(Get-JiraSession).WebSession

        #To Do: Add support for paged responses
        if($response.isLastPage -eq $false){Throw "The response is paged. This function does not support paged responses."}
        if($Project){$response.values | Where-Object {$_.projectKey -eq $Project}}else{$response.values}

    }
    end {
        # End of function
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
