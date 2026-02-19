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

Moves one or more PSNotes to a different catalog.

## SYNTAX

### __AllParameterSets

```
Move-PSNote [-InputObject] <PSNote> [-DestinationCatalog] <string> [-Force] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Move-PSNote changes the catalog assignment of existing PSNotes.
This allows you to reorganize
your note library as it grows without recreating notes.

You can specify notes directly by name, alias, or other supported parameters, or pipe PSNote
objects from Get-PSNote.

This cmdlet updates the note metadata and persists the changes to the PSNotes store.
Supports ShouldProcess, enabling the use of -WhatIf and -Confirm.

## EXAMPLES

### EXAMPLE 1

```powershell
Move-PSNote -Name 'Get-VMInfo' -Catalog 'Azure'
```

Moves the note named 'Get-VMInfo' to the Azure catalog.

### EXAMPLE 2

```powershell
Get-PSNote -Catalog 'General' | Move-PSNote -Catalog 'Archive'
```

Moves all notes from the General catalog to the Archive catalog.

### EXAMPLE 3

```powershell
Move-PSNote -Alias 'azvm' -Catalog 'Azure' -WhatIf
```

Shows what would happen if the note were moved, without performing the action.

### EXAMPLE 4

```powershell
Get-PSNote -Tag 'Legacy' | Move-PSNote -Catalog 'Archive' -Force -PassThru
```

Moves all notes tagged 'Legacy' into the Archive catalog without prompting and returns the updated notes.

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

Suppresses confirmation prompts when moving notes.

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

One or more PSNote objects to move.
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

Returns the moved PSNote objects.

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


## OUTPUTS

### PSNote


## NOTES

- Supports -WhatIf and -Confirm through ShouldProcess.
- Use Get-PSNote to identify notes before moving them.
- See also: Get-PSNote, Set-PSNote, Remove-PSNote


## RELATED LINKS


