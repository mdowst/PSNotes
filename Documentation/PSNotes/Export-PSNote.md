---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Export-PSNote
---

# Export-PSNote

## SYNOPSIS

Exports PSNotes to a JSON file for backup or sharing.

## SYNTAX

### Note (Default)

```
Export-PSNote -NoteObject <PSNote[]> -Path <string> [-Force] [<CommonParameters>]
```

### Catalog

```
Export-PSNote -Catalog <string> -Path <string> [-Force] [<CommonParameters>]
```

## DESCRIPTION

Export-PSNote serializes notes from the PSNotes store into a JSON file.
You can export the entire
store or a filtered subset of notes (for example, by name, alias, tag, or catalog depending on
the parameter set in use).

The exported file is designed to round-trip with Import-PSNote and can be used for backups,
migration to another machine, or sharing curated note collections.

If the destination file already exists, use -Force to overwrite it.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-PSNote -Catalog 'Default' -Path C:\Export\MyPSNotes.json
```

Exports all notes from the 'Default' catalog to a JSON file.

### EXAMPLE 2

```powershell
Get-PSNote -Tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json
```

Exports all notes with the tag 'AD' to the file SharedADNotes.json.

### EXAMPLE 3

```powershell
Get-PSNote -Note 'Cred*' -Catalog 'Work' | Export-PSNote -Path C:\Export\WorkCreds.json
```

Exports notes that match the name pattern from the 'Work' catalog.

### EXAMPLE 4

```powershell
Get-PSNote -SearchString 'token' | Export-PSNote -Path C:\Export\TokenNotes.json
```

Exports notes that match a search string.

### EXAMPLE 5

```powershell
Export-PSNote -Catalog 'Personal' -Path C:\Export\PersonalNotes.json -Force
```

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


## OUTPUTS

### System.Object


## NOTES

- The exported JSON file is intended for use with Import-PSNote.
- Use -Force to overwrite an existing file.
- See also: Import-PSNote, Get-PSNote


## RELATED LINKS


