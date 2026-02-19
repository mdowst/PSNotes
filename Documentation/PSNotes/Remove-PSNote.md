---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Remove-PSNote
---

# Remove-PSNote

## SYNOPSIS

Removes one or more PSNotes from the note store.

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

## DESCRIPTION

Remove-PSNote deletes notes from the PSNotes store.
You can target notes by name, alias,
catalog, tag, or by piping PSNote objects from Get-PSNote.

This cmdlet updates the store immediately and permanently removes the selected notes.
Supports ShouldProcess, enabling the use of -WhatIf and -Confirm for safer operations.

Use -Force to suppress confirmation prompts where applicable.

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-PSNote -Name 'OldNote'
```

Removes the note named 'OldNote'.

### EXAMPLE 2

```powershell
Get-PSNote -Catalog 'Archive' | Remove-PSNote
```

Removes all notes in the Archive catalog.

### EXAMPLE 3

```powershell
Remove-PSNote -Alias 'azvm' -WhatIf
```

Shows what would happen if the note with alias 'azvm' were removed.

### EXAMPLE 4

```powershell
Get-PSNote -Tag 'Legacy' | Remove-PSNote -Force -PassThru
```

Removes all notes tagged 'Legacy' without prompting and returns the removed note objects.

## PARAMETERS

### -Catalog

Removes notes from the specified catalog.

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

Suppresses confirmation prompts.

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

One or more PSNote objects to remove.
Accepts pipeline input from Get-PSNote.

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

Discovery params (match Get-PSNote)

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

Removes notes that contain one or more specified tags.

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


## OUTPUTS

### PSNote


## NOTES

- Supports -WhatIf and -Confirm through ShouldProcess.
- Deletions are permanent once committed.
- Use Get-PSNote to preview notes before removing them.
- See also: Get-PSNote, New-PSNote, Set-PSNote, Move-PSNote


## RELATED LINKS


