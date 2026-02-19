---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Initialize-PSNoteStore
---

# Initialize-PSNoteStore

## SYNOPSIS

Initialize the PSNotes store

## SYNTAX

### __AllParameterSets

```
Initialize-PSNoteStore [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Loads all PSNotes catalogs from $env:PSNOTES_HOME into the in-memory note store
and verifies clipboard support.
This is typically called internally by other
commands, but can be invoked to refresh the store after external changes.

## EXAMPLES

### EXAMPLE 1

Initialize-PSNoteStore

Initializes the PSNotes store by loading catalogs from $env:PSNOTES_HOME.

### EXAMPLE 2

$env:PSNOTES_HOME = 'C:\Users\Me\AppData\Roaming\PSNotes'
Initialize-PSNoteStore

Initializes the store using a custom PSNotes home path.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
