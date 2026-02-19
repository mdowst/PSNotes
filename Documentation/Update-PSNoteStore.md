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

Updates PSNotes catalogs to the latest format.

## SYNTAX

### __AllParameterSets

```
Update-PSNoteStore [[-DefaultBehavior] <string>] [<CommonParameters>]
```

## DESCRIPTION

Update-PSNoteStore scans the PSNotes home directory for JSON catalogs and migrates any catalogs
that are not in the current format.
Migrated content is then imported back into the PSNotes
store using the specified conflict behavior.

Use -DefaultBehavior to control how note conflicts are handled during import:
- Prompt: prompts when conflicts occur
- SkipMigratedNotes: keeps existing notes and skips conflicting migrated notes
- OverwriteExistingNotes: overwrites existing notes with migrated versions

## EXAMPLES

### EXAMPLE 1

```powershell
Update-PSNoteStore
```

Migrates any outdated catalogs and prompts when conflicts occur.

### EXAMPLE 2

```powershell
Update-PSNoteStore -DefaultBehavior SkipMigratedNotes
```

Migrates catalogs and skips notes that already exist.

### EXAMPLE 3

```powershell
Update-PSNoteStore -DefaultBehavior OverwriteExistingNotes
```

Migrates catalogs and overwrites existing notes when conflicts occur.

## PARAMETERS

### -DefaultBehavior

Determines how to handle existing notes when conflicts are detected during import.

Valid values:
- Prompt
- SkipMigratedNotes
- OverwriteExistingNotes

The default is 'Prompt'.

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

- This cmdlet migrates catalogs discovered under $env:PSNOTES_HOME.
- Conflict behavior applies when importing migrated notes back into the store.
- See also: Initialize-PSNoteStore, Import-PSNote, Export-PSNote


## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
