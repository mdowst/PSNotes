---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Import-PSNote
---

# Import-PSNote

## SYNOPSIS

Imports PSNotes from a JSON export file into the local note store.

## SYNTAX

### Note (Default)

```
Import-PSNote [-Path] <string> [[-Catalog] <string>] [[-DefaultBehavior] <string>]
 [<CommonParameters>]
```

## DESCRIPTION

Import-PSNote reads a PSNotes JSON export file and imports the contained notes into the local
PSNotes store.

Import behavior may merge with existing notes or create new notes depending on the options
provided and the contents of the import file.
Use -Force (if supported) to overwrite existing
notes when conflicts occur.

This cmdlet is commonly used to restore backups created by Export-PSNote, migrate notes between
machines, or share curated note libraries.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-PSNote -Path .\backup.json
```

Imports all notes from backup.json into the local store.

### EXAMPLE 2

```powershell
Import-PSNote -Path .\azure-notes.json -Catalog 'Azure'
```

Imports notes from azure-notes.json and places them into the Azure catalog (if supported).

### EXAMPLE 3

```powershell
Import-PSNote -Path .\backup.json -DefaultBehavior OverwriteExistingNotes
```

Imports notes, overwriting conflicts, and returns the imported note objects.

## PARAMETERS

### -Catalog

Imports notes into the specified catalog (or maps imported notes into that catalog depending on implementation).

```yaml
Type: System.String
DefaultValue: Default
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DefaultBehavior

Determines how to handle existing notes when conflicts are detected during import.
Valid values:
- Prompt: prompts when conflicts occur
- SkipMigratedNotes: keeps existing notes and skips conflicting imported notes
- OverwriteExistingNotes: overwrites existing notes with imported versions

```yaml
Type: System.String
DefaultValue: Prompt
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

### -Path

The path to the PSNotes JSON file to import.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object


## NOTES

- This cmdlet is designed to round-trip with Export-PSNote.
- If you encounter format/version differences after upgrading PSNotes, run Update-PSNoteStore.
- See also: Export-PSNote, Get-PSNote, Update-PSNoteStore


## RELATED LINKS


