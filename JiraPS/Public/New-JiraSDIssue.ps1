function New-JiraSDIssue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('ProjectKey')]
        [String]
        $Project,

        [Parameter(Mandatory = $true)]
        [Alias('RequestType')]
        [String]
        $Request,

        [Parameter(Mandatory = $true)]
        [String]
        $Reporter,

        [Parameter(Mandatory = $true)]
        [String]
        $Summary,

        [Parameter(Mandatory = $false)]
        [String]
        $Description,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )



    begin {

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        # Get Jira server information
        $server = Get-JiraConfigServer -ErrorAction Stop

        if(!$Credential -and !(Get-JiraSession)){Throw "No credentials provided and no active session found."}
        elseif(!(Get-JiraSession)){
            Write-Verbose "No active session found. Creating a new session..."
            New-JiraSession -Credential $Credential
        }

        Write-Verbose "Check for Project Key"
        $SDObj = Get-JiraServiceDesk -ProjectKey $Project -ErrorAction Stop

        Write-Verbose "Check For Request Type"
        $RequestObj = Get-JiraRequestType -Project $Project -RequestType $Request -ErrorAction Stop

        Write-Verbose "Check For Reporter"
        $ReporterObj = Get-JiraCustomer -Project $Project -Query $Reporter -ErrorAction Stop

        # Construct URI based on parameters
        $Uri = "$server/rest/servicedeskapi/request"

    }

    process {
        $requestBody = @{
            requestFieldValues = @{
                summary     = $Summary
                description = $Description
            }
            serviceDeskId = "$($SDObj.id)"
            requestTypeId = "$($RequestObj.id)"
            raiseOnBehalfOf = "$($ReporterObj.accountId)"
        } | ConvertTo-Json -Compress
        # If other optional fields were specified, add them to the hashtable
        $Issue = Invoke-RestMethod -ContentType 'application/json' -Method Post -Uri $Uri -Body $requestBody -WebSession $(Get-JiraSession).WebSession
        Write-Output (Get-JiraIssue $Issue.issueKey)
    }
    end {
        Write-Verbose "Jira customer retrieval complete."
    }
}
