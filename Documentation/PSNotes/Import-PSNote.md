---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Import-PSNote
---

# Import-PSNote

## SYNOPSIS

Import a PSNotes JSON file

## SYNTAX

### Note (Default)

```
Import-PSNote [-Path] <string> [[-Catalog] <string>] [[-DefaultBehavior] <string>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Imports PSNotes from a JSON catalog file into your local note store.
You can import into the default
catalog or a named catalog, and control how existing notes are handled.

## EXAMPLES

### EXAMPLE 1

Import-PSNote -Path C:\Import\MyPSNotes.json

Imports the contents of MyPSNotes.json into the Default catalog.

### EXAMPLE 2

Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'

Imports the contents of MyPSNotes.json into the ADNotes catalog.

### EXAMPLE 3

Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'Work' -DefaultBehavior OverwriteExistingNotes

Imports into the Work catalog and overwrites existing notes when conflicts occur.

## PARAMETERS

### -Catalog

The destination catalog name to import into.
Defaults to 'Default'.

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

Determines how to handle existing notes when conflicts are detected.
Valid values: Prompt, SkipMigratedNotes, OverwriteExistingNotes.

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

The path to the PSNotes JSON catalog file to import.

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

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
