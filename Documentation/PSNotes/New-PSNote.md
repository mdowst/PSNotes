---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: New-PSNote
---

# New-PSNote

## SYNOPSIS

Creates a new PSNote for storing reusable snippets or script references.

## SYNTAX

### Note (Default)

```
New-PSNote -Note <string> [-Details <string>] [-Alias <string>] [-Tags <string[]>]
 [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Snippet

```
New-PSNote -Note <string> [-Snippet <string>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ScriptBlock

```
New-PSNote -Note <string> [-ScriptBlock <scriptblock>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ScriptPath

```
New-PSNote -Note <string> [-ScriptPath <string>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

New-PSNote creates a note in the PSNotes store that can represent either:

- A reusable PowerShell snippet (inline code)
- A script reference (a path to a script file to execute)

Notes can include metadata such as catalog, alias, and tags to make them easier to organize and
retrieve later.
Once created, notes can be recalled using Get-PSNote, invoked quickly by alias
with Get-PSNoteAlias, or selected interactively using Get-PSNoteMenu.

This cmdlet supports ShouldProcess, enabling -WhatIf and -Confirm.

## EXAMPLES

### EXAMPLE 1

```powershell
New-PSNote -Name 'List-AzVMs' -Catalog 'Azure' -Alias 'azvms' -Tag 'VM','Azure' -Snippet 'Get-AzVM'
```

Creates a snippet note named List-AzVMs in the Azure catalog with an alias and tags.

### EXAMPLE 2

```powershell
New-PSNote -Name 'Build' -Catalog 'Dev' -Alias 'build' -ScriptPath 'C:\Scripts\Build.ps1'
```

Creates a script-path note that references a script to run later.

### EXAMPLE 3

```powershell
New-PSNote -Name 'TestNote' -Catalog 'General' -Snippet 'Get-Date' -WhatIf
```

Shows what would happen if the note were created without making changes.

### EXAMPLE 4

```powershell
New-PSNote -Name 'List-AzVMs' -Catalog 'Azure' -Snippet 'Get-AzVM' -Force -PassThru
```

Overwrites an existing note (if present) and returns the created note object.

## PARAMETERS

### -Alias

An optional short alias used for quick recall (for example, with Get-PSNoteAlias).

```yaml
Type: System.String
DefaultValue: ''
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

### -Catalog

The catalog to create the note in.

```yaml
Type: System.String
DefaultValue: Default
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

### -Details


```yaml
Type: System.String
DefaultValue: ''
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

### -Force

Overwrites an existing note with the same name (or alias conflict) where supported.

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

### -Note


```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Run


```yaml
Type: System.Boolean
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

### -ScriptBlock


```yaml
Type: System.Management.Automation.ScriptBlock
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ScriptBlock
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptPath

A script path to store in the note for later execution.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ScriptPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Snippet

The PowerShell snippet content to store in the note.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Snippet
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tags


```yaml
Type: System.String[]
DefaultValue: ''
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

## OUTPUTS

### PSNote


## NOTES

- Supports -WhatIf and -Confirm through ShouldProcess.
- Notes may be uniquely identified by name and/or alias depending on store rules.
- Use Set-PSNote to update an existing note.
- See also: Get-PSNote, Set-PSNote, Get-PSNoteAlias, Get-PSNoteMenu


## RELATED LINKS


