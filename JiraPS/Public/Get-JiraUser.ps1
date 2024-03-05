function Get-JiraUser {
    # Define command parameters
    [CmdletBinding(DefaultParameterSetName = 'ByUserID')]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'ByQuery')]
        [AllowEmptyString()]
        [Alias('Query')]
        [String[]]
        $Querystring,

        [Parameter(ParameterSetName = 'ByQuery')]
        [Alias('ProjectAssignmentKey')]
        [String]
        $AssignableToProject,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateRange(1, 1000)]
        [UInt32]
        $MaxResults = 50,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateNotNullOrEmpty()]
        [UInt64]
        $Skip = 0,

        [Parameter(ParameterSetName = 'ByUserID')]
        [AllowEmptyString()]
        [Alias('UserID')]
        [String[]]
        $AccountId,

        [Switch]
        $IncludeInactive,

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
        if ($AssignableToProject) {
            $ProjectObject = Get-JiraProject -Project $AssignableToProject -ErrorAction Stop
            $searchResourceUri = "$server/rest/api/3/user/assignable/search?query={0}&project=$($ProjectObject.Key)"
        } else {
            $searchResourceUri = "$server/rest/api/3/user/search?query={0}"
        }

        # Exact URI for user lookup
        $exactResourceUri = "$server/rest/api/3/user?accountId={0}"

        # Append additional parameters if specified
        if ($IncludeInactive) {
            $searchResourceUri += "&includeInactive=true"
        }
        if ($MaxResults) {
            $searchResourceUri += "&maxResults=$MaxResults"
        }
        if ($Skip) {
            $searchResourceUri += "&startAt=$Skip"
        }
    }

    process {
        # Process each input item
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Determine action based on parameter set
        switch ($PsCmdlet.ParameterSetName) {
            "ByUserID" {
                # Lookup users by user ID
                $resourceURi = $exactResourceUri #Always exact.
                $ids = $AccountId
            }
            "ByQuery" {
                # Lookup users by query string
                $resourceURi = $searchResourceUri #Always search.
                $ids = $Querystring
            }
        }

        # Invoke API to retrieve user information
        foreach ($id in $ids) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing ID [$id]"
            $parameter = @{
                URI        = $resourceURi -f $id
                Method     = "GET"
                Credential = $Credential
            }

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($users = Invoke-JiraMethod @parameter) {
                foreach ($item in $users) {
                    $parameter = @{
                        URI        = "{0}&expand=groups" -f $item.self
                        Method     = "GET"
                        Credential = $Credential
                    }
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    $result = Invoke-JiraMethod @parameter

                    Write-Output (ConvertTo-JiraUser -InputObject $result)
                }
            } else {
                # No user found, output error message
                $errorMessage = @{
                    Category         = "ObjectNotFound"
                    CategoryActivity = "Searching for user"
                    Message          = "No results when searching for user $id"
                }
                Write-Error @errorMessage
            }
        }
    }

    end {
        # End of function
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
