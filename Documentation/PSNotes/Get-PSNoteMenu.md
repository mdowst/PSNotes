---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-PSNoteMenu
---

# Get-PSNoteMenu

## SYNOPSIS

Displays an interactive, paged menu of PSNotes and lets the user pick one by number.

## SYNTAX

### __AllParameterSets

```
Get-PSNoteMenu [[-InputObject] <Object>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Renders notes in a numbered, multi-column list sized to the current console window.
Prompts for a number to select a note, or Enter to advance to the next page.

Output:
  - Returns the selected PSNote object (or $null if quit / nothing selected).

Assumptions:
  - Get-PSNote returns objects with (at least) Catalog, Alias, and Note properties.
    (If Catalog is missing/empty, it displays "Default".)

## EXAMPLES

### EXAMPLE 1

$note = Get-PSNoteMenu

## PARAMETERS

### -InputObject

{{ Fill InputObject Description }}

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
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

{{ Fill in the related links here }}

