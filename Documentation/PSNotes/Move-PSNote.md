---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Move-PSNote
---

# Move-PSNote

## SYNOPSIS

Moves a note to a different catalog.

## SYNTAX

### __AllParameterSets

```
Move-PSNote [-InputObject] <PSNote> [-DestinationCatalog] <string> [-Force] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Moves a note from its current catalog to another catalog.
Supports
confirmation prompts via ShouldProcess.

## EXAMPLES

### EXAMPLE 1

Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work'
Moves the note named 'Install-Module' to the 'Work' catalog.

### EXAMPLE 2

Get-PSNote -Catalog 'Personal' | Move-PSNote -DestinationCatalog 'Archive' -Force
Moves all notes from 'Personal' to 'Archive', overwriting duplicates.

### EXAMPLE 3

Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work' -PassThru
Moves the note and returns the moved note object.

## PARAMETERS

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

### -DestinationCatalog

The target catalog name to move the note to.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Overwrites the destination note if it already exists.

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

The note to move.
Accepts pipeline input from Get-PSNote.

```yaml
Type: PSNote
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PassThru

Returns the moved note object.

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

### PSNote

{{ Fill in the Description }}

## OUTPUTS

### PSNote
Returns note objects when -PassThru is specified; otherwise returns nothing.

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

- [Get-PSNote
Set-PSNote
Remove-PSNote]()
