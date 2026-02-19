---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-CommandSplatting
---

# Get-CommandSplatting

## SYNOPSIS

Generates a splatting template for a PowerShell command.

## SYNTAX

### ParameterSet (Default)

```
Get-CommandSplatting [-Command] <string> [[-ParameterSet] <string>] [-IncludeCommon] [-Copy]
 [<CommonParameters>]
```

### ListParameterSets

```
Get-CommandSplatting [-Command] <string> [-ListParameterSets] [-IncludeCommon] [-Copy]
 [<CommonParameters>]
```

### All

```
Get-CommandSplatting [-Command] <string> [-All] [-IncludeCommon] [-Copy] [<CommonParameters>]
```

## DESCRIPTION

Get-CommandSplatting inspects a command’s parameter metadata and produces a ready-to-paste splatting
template.
It returns one or more objects that include:

- A variable “set block” with typed variable declarations for each parameter
- A hashtable “hash block” formatted for splatting (including required-parameter comments)
- A final example invocation that splats the hashtable into the command

By default, the cmdlet outputs the default parameter set for the command.
You can list available
parameter sets, generate a specific parameter set, or generate templates for all parameter sets.
Optionally include the PowerShell common parameters and/or copy the first generated template to the
clipboard.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-CommandSplatting -Command 'Get-Item'
```

Generates a splatting template for the default parameter set of Get-Item.

### EXAMPLE 2

```powershell
Get-CommandSplatting -Command 'Get-Item' -ListParameterSets
```

Lists the available parameter sets for Get-Item and shows the parameters included in each set.

### EXAMPLE 3

```powershell
Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath
```

Generates a splatting template for the LiteralPath parameter set.

### EXAMPLE 4

```powershell
Get-CommandSplatting -Command 'Get-Item' -All
```

Generates splatting templates for all parameter sets of Get-Item.

### EXAMPLE 5

```powershell
Get-CommandSplatting -Command 'Get-Item' -IncludeCommon -Copy
```

Generates the default parameter set template including common parameters and copies the first template to the clipboard.

## PARAMETERS

### -All

Generates splatting templates for all parameter sets for the specified command.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: All
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Command

The name of the command to generate a splatting template for (cmdlet/function/alias supported by Get-Command).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Copy

Copies the first generated template (SetBlock + HashBlock) to the clipboard.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IncludeCommon

Includes PowerShell common parameters (for example: Verbose, Debug, ErrorAction) in the generated output.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ListParameterSets

Lists available parameter sets for the specified command, including whether each set is the default and the
parameter names in that set.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ListParameterSets
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ParameterSet

The name of a specific parameter set to generate.
Use -ListParameterSets to discover available names.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ParameterSet
  Position: 1
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

### SplatBlock


## NOTES

- Required parameters are annotated in the hashtable output with a "#Required" comment.
- Switch parameters are represented as [Boolean] variables in the set block, defaulting to $false.
- Use -ListParameterSets to discover parameter set names before using -ParameterSet.


## RELATED LINKS


