---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-PSNote
---

# Get-PSNote

## SYNOPSIS

Search for or list PSNotes

## SYNTAX

### Note (Default)

```
Get-PSNote [-Note <string>] [-Tag <string>] [-Copy] [-Run] [-Catalog <string[]>]
 [<CommonParameters>]
```

### Search

```
Get-PSNote [-Run] [-Catalog <string[]>] [-Search <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Searches notes by name, tag, or text across all note properties.
You can also
filter by catalog and optionally copy or run the returned snippet.

## EXAMPLES

### EXAMPLE 1

Get-PSNote

Returns all notes.

### EXAMPLE 2

Get-PSNote -Note 'Creds'

Returns the note named 'Creds'.

### EXAMPLE 3

Get-PSNote -Note 'Cred*'

Returns all notes with names that start with 'Cred'.

### EXAMPLE 4

Get-PSNote -Tag 'AD'

Returns all notes with the tag 'AD'.

### EXAMPLE 5

Get-PSNote -Note '*User*' -Tag 'AD'

Returns notes with 'User' in the name and the tag 'AD'.

### EXAMPLE 6

Get-PSNote -SearchString 'day'

Returns notes where 'day' appears in the name, details, snippet, alias, or tags.

### EXAMPLE 7

Get-PSNote -Catalog 'Default'

Returns all notes in the Default catalog.

### EXAMPLE 8

Get-PSNote -SearchString 'day' -Catalog 'Work*','Personal*'

Searches only within the matching catalogs.

### EXAMPLE 9

Get-PSNote -Note 'CpuUsage' -Copy

Copies the snippet for the selected note to the clipboard.

### EXAMPLE 10

Get-PSNote -SearchString 'token' -Run

Runs the selected note; prompts to choose if multiple notes match.

## PARAMETERS

### -Catalog

Filter notes by catalog name.
Accepts wildcards and multiple values.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Search
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Note
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Copy

Copy the selected snippet to the clipboard.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Note
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Note

The note name to return.
Accepts wildcards.

```yaml
Type: System.String
DefaultValue: '*'
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Note
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Run

Run the selected snippet via Invoke-PSNote.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Search
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: Note
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Search

{{ Fill Search Description }}

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- SearchString
ParameterSets:
- Name: Search
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tag

Return notes that contain the specified tag.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Note
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
