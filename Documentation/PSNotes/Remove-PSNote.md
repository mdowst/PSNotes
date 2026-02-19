---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Remove-PSNote
---

# Remove-PSNote

## SYNOPSIS

Remove one or more PSNotes from the note store.

## SYNTAX

### Note (Default)

```
Remove-PSNote [-Note <string>] [-Tag <string>] [-Catalog <string[]>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByObject

```
Remove-PSNote -InputObject <Object> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Search

```
Remove-PSNote -SearchString <string> [-Catalog <string[]>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

You can remove notes by piping results from Get-PSNote, or by using the same
discovery parameters (Note/Tag/Catalog/SearchString) to select notes to remove.

## EXAMPLES

### EXAMPLE 1

Get-PSNote -SearchString 'cred' -Catalog 'Work*' | Remove-PSNote

Removes notes matched by search string from catalogs that start with 'Work'.

### EXAMPLE 2

Remove-PSNote -Note 'cred*' -Catalog 'Default'

Removes notes with names starting with 'cred' from the Default catalog.

### EXAMPLE 3

Remove-PSNote -SearchString 'token' -Catalog 'Work*','Personal*' -Force

Removes notes matching 'token' in the Work and Personal catalogs without confirmation.

### EXAMPLE 4

Get-PSNote -Tag 'deprecated' | Remove-PSNote -Force

Removes all notes tagged 'deprecated' via pipeline without confirmation.

## PARAMETERS

### -Catalog

Filter by catalog name (wildcards supported; accepts multiple values).

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

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Suppress confirmation prompts (still honors -WhatIf).

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -InputObject

Pipeline input (typically from Get-PSNote).

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByObject
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Note

Note name pattern (wildcards supported).
Defaults to '*'.

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

### -SearchString

Free-text search across Note/Alias/Details/Snippet/Tags.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Search
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tag

Filter by tag (exact match, consistent with Get-PSNote).

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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
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

### System.Object

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
