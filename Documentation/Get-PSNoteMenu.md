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

Displays an interactive, paged console menu for browsing and selecting PSNotes.

## SYNTAX

### __AllParameterSets

```
Get-PSNoteMenu [[-InputObject] <Object>] [<CommonParameters>]
```

## DESCRIPTION

Get-PSNoteMenu presents PSNotes in an interactive terminal-based menu with paging support.
Users can navigate through notes, select one by number, and then choose an action such as:

- Output the note content
- Copy the note to the clipboard
- Execute the snippet
- Execute a referenced script path

The menu is designed to provide a streamlined console experience for browsing catalogs,
favorites, or filtered note sets.
When multiple pages are present, page indicators
(for example, "Page 1/3") are shown.

This cmdlet is intended for interactive use within the current console session.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-PSNoteMenu
```

Displays all notes in an interactive menu.

## PARAMETERS

### -InputObject

A collection of PSNote objects to display.
Accepts pipeline input from Get-PSNote.

If not provided, all notes are displayed by default.

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


## OUTPUTS

### PSNote


## NOTES

- Designed for interactive terminal use.
- Supports paging when the number of notes exceeds the configured page size.
- After selecting a note, a secondary action menu is displayed (output, copy, run).
- See also: Get-PSNote, Get-PSNoteAlias, Start-PSNote


## RELATED LINKS


