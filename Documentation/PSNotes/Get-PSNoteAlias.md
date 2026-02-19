---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-PSNoteAlias
---

# Get-PSNoteAlias

## SYNOPSIS

Resolves a PSNote by alias and outputs, copies, or executes its content.

## SYNTAX

### __AllParameterSets

```
Get-PSNoteAlias [-Copy] [-Run] [<CommonParameters>]
```

## DESCRIPTION

Get-PSNoteAlias locates a PSNote using its alias and performs a quick action against it.

Depending on the note’s Kind and the parameters supplied, the cmdlet can:

- Output the snippet content to the console
- Copy the snippet content to the clipboard
- Execute the snippet directly
- Execute a referenced script path

This command is designed for fast recall of frequently used commands through short,
easy-to-remember aliases.

## EXAMPLES

## PARAMETERS

### -Copy

Copies the note content to the clipboard instead of writing it to the console.

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

### -Run

Executes the note content.
For snippet notes, the script block is invoked.
For script-path
notes, the referenced script is executed.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String


## NOTES

- Alias values are intended to be unique within the PSNotes store.
- Behavior differs based on the note Kind (for example, Snippet vs ScriptPath).
- Clipboard functionality depends on platform support.
- See also: Get-PSNote, New-PSNote, Set-PSNote


## RELATED LINKS


