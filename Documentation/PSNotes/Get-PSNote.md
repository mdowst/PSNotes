---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-PSNote
---

# Get-PSNote

## SYNOPSIS

Retrieves PSNotes from the note store by listing or searching.

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

## DESCRIPTION

Get-PSNote returns notes stored in the PSNotes store.
By default, all notes are returned.
You can filter results by name, alias, tag, catalog, or search text depending on the
parameter set in use.

This cmdlet returns PSNote objects that can be piped into other PSNotes commands such as
Remove-PSNote, Move-PSNote, Export-PSNote, or Set-PSNote.

Wildcard matching is supported where applicable.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PSNote
```

Returns all notes in the store.

### EXAMPLE 2

```powershell
Get-PSNote -Catalog 'Azure'
```

Returns all notes in the Azure catalog.

### EXAMPLE 3

```powershell
Get-PSNote -Name 'Get-*'
```

Returns notes with names that match the pattern.

### EXAMPLE 4

```powershell
Get-PSNote -Tag 'VM'
```

Returns notes tagged with 'VM'.

### EXAMPLE 5

```powershell
Get-PSNote -Search 'backup'
```

Searches across note properties for the term 'backup'.

### EXAMPLE 6

```powershell
Get-PSNote -Catalog 'Azure' | Remove-PSNote
```

Finds notes in the Azure catalog and removes them.

## PARAMETERS

### -Catalog

Returns notes from the specified catalog.

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

Performs a broader search across note properties such as name, alias, and tags.

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

Returns notes that contain one or more specified tags.

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

### PSNote


## NOTES

- Returns PSNote objects.
- Wildcards are supported for Name and Alias parameters.
- See also: New-PSNote, Set-PSNote, Remove-PSNote, Move-PSNote, Export-PSNote


## RELATED LINKS


