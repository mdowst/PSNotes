---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Export-PSNote
---

# Export-PSNote

## SYNOPSIS

Export PSNotes to a JSON file

## SYNTAX

### Note (Default)

```
Export-PSNote -NoteObject <PSNote[]> -Path <string> [-Force] [<CommonParameters>]
```

### Catalog

```
Export-PSNote -Catalog <string> -Path <string> [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Exports PSNotes to a JSON file for sharing or importing on another machine.
You can export notes by catalog or by piping PSNote objects into this command.

## EXAMPLES

### EXAMPLE 1

Export-PSNote -Catalog 'Default' -Path C:\Export\MyPSNotes.json

Exports all notes from the 'Default' catalog to a JSON file.

### EXAMPLE 2

Get-PSNote -Tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json

Exports all notes with the tag 'AD' to the file SharedADNotes.json.

### EXAMPLE 3

Get-PSNote -Note 'Cred*' -Catalog 'Work' | Export-PSNote -Path C:\Export\WorkCreds.json

Exports notes that match the name pattern from the 'Work' catalog.

### EXAMPLE 4

Get-PSNote -SearchString 'token' | Export-PSNote -Path C:\Export\TokenNotes.json

Exports notes that match a search string.

### EXAMPLE 5

Export-PSNote -Catalog 'Personal' -Path C:\Export\PersonalNotes.json -Force

Exports the 'Personal' catalog and overwrites the file if it exists.

## PARAMETERS

### -Catalog

The catalog name to export.
When specified, all notes from that catalog are exported.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Catalog
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Force

Overwrite the output file if it already exists.

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

### -NoteObject

The PSNote objects you want to export.
Use Get-PSNote to build the object and pass it to the parameter
or use the pipeline to pass them in.

```yaml
Type: PSNote[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Note
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

The path to the PSNotes JSON file to export to.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
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

### PSNote[]

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
