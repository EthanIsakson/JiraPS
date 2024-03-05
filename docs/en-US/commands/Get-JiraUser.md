---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Get-JiraUser/
locale: en-US
schema: 3.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Get-JiraUser/
---
# Get-JiraUser

## SYNOPSIS

Returns a user from Jira

## SYNTAX

### Self (Default)

```powershell
Get-JiraUser [-Credential <PSCredential>] [<CommonParameters>]
```

### ByQuery

```powershell
Get-JiraUser [-Querystring] <String[]> [-AssignableToProject <String>] [-MaxResults <UInt32>] [-Skip <UInt64>] [-IncludeInactive] [-Credential <PSCredential>] [<CommonParameters>]
```

### ByUserID

```powershell
Get-JiraUser [-AccountId] <String[]> [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This function returns information regarding a specified user from Jira.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-JiraUser -Querystring user1
```

Returns information about all users with emailaddress,displayname like user1

### EXAMPLE 2

```powershell
Get-ADUser -filter "Name -like 'John*Smith'" | Select-Object -ExpandProperty samAccountName | Get-JiraUser -Credential $cred
```

This example searches Active Directory for "John*Smith", then obtains their JIRA user accounts.

### EXAMPLE 3

```powershell
Get-JiraUser -Credential $cred
```

This example returns the JIRA user that is executing the command.

### EXAMPLE 4

```powershell 
Get-JiraUser -AccountID "47935-c458cd-s84h3"
```

Returns information about user with accountID 47935-c458cd-s84h3

## PARAMETERS

### -Querystring

Query string to search for users.

```yaml
Type: String[]
Parameter Sets: ByQuery
Aliases: Query

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AssignableToProject

Key of the project to which users should be assignable.

```yaml
Type: String
Parameter Sets: ByQuery
Aliases: ProjectAssignmentKey

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountId

Account ID of the user.

```yaml
Type: String[]
Parameter Sets: ByUserID
Aliases: UserID

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False

```

### -IncludeInactive

Include inactive users in the search

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxResults

Maximum number of user to be returned.

> The API does not allow for any value higher than 1000.

```yaml
Type: UInt32
Parameter Sets: ByUserName
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip

Controls how many objects will be skipped before starting output.

Defaults to 0.

```yaml
Type: UInt64
Parameter Sets: ByUserName
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Credentials to use to connect to JIRA.
If not specified, this function will use anonymous access.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [String[]]

DisplayName, name, or e-mail address

## OUTPUTS

### [JiraPS.User]

## NOTES

This function requires either the `-Credential` parameter to be passed or a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[New-JiraUser](../New-JiraUser/)

[Remove-JiraUser](../Remove-JiraUser/)
