---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Initialize-PSNoteStore
---

# Initialize-PSNoteStore

## SYNOPSIS

Initializes the PSNotes store and required supporting files.

## SYNTAX

### __AllParameterSets

```
Initialize-PSNoteStore [<CommonParameters>]
```

## DESCRIPTION

Initialize-PSNoteStore ensures the PSNotes store is present and ready for use.
It creates the
required folder structure and base configuration files when they do not already exist.

This cmdlet is typically invoked automatically by other PSNotes commands as needed, but it can
also be called directly when setting up PSNotes on a new machine or when repairing an incomplete
store.

## EXAMPLES

### EXAMPLE 1

```powershell
Initialize-PSNoteStore
```

Initializes the PSNotes store using the default location.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object


## NOTES

- This cmdlet prepares the store layout and configuration required by the PSNotes module.
- Most PSNotes commands will initialize the store automatically when needed.
- See also: Update-PSNoteStore, Get-PSNote


## RELATED LINKS


