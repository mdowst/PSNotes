---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Update-PSNoteStore
---

# Update-PSNoteStore

## SYNOPSIS

Update PSNotes catalogs to the latest format

## SYNTAX

### __AllParameterSets

```
Update-PSNoteStore [[-DefaultBehavior] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Scans the PSNotes home directory for JSON catalogs and migrates any
catalogs that are not in the current format.
Migration results are
imported back into the store using the specified conflict behavior.

## EXAMPLES

### EXAMPLE 1

Update-PSNoteStore

Migrates any outdated catalogs and prompts when conflicts occur.

### EXAMPLE 2

Update-PSNoteStore -DefaultBehavior SkipMigratedNotes

Migrates catalogs and skips notes that already exist.

### EXAMPLE 3

Update-PSNoteStore -DefaultBehavior OverwriteExistingNotes

Migrates catalogs and overwrites existing notes when conflicts occur.

## PARAMETERS

### -DefaultBehavior

Determines how to handle existing notes when conflicts are detected.
Valid values: Prompt, SkipMigratedNotes, OverwriteExistingNotes.

```yaml
Type: System.String
DefaultValue: Prompt
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
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

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
