---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-RemoteCatalog
---

# Get-RemoteCatalog

## SYNOPSIS

Gets remote catalogs registered with PSNotes.

## SYNTAX

### __AllParameterSets

```
Get-RemoteCatalog [[-Catalog] <string>] [<CommonParameters>]
```

## DESCRIPTION

Get-RemoteCatalog retrieves remote catalog registrations from the PSNotes configuration.
Remote catalogs
represent external sources (such as a URL) that can be imported into PSNotes or kept registered for future
imports.

Use -Catalog to return a specific remote catalog by name, or provide a wildcard pattern to match multiple
registrations.
If no remote catalogs are configured, this cmdlet returns an empty array.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-RemoteCatalog
```

Returns all configured remote catalogs.

### EXAMPLE 2

```powershell
Get-RemoteCatalog -Catalog 'github'
```

Returns the remote catalog registration named 'github'.

### EXAMPLE 3

```powershell
Get-RemoteCatalog -Catalog 'git*'
```

Returns all remote catalog registrations with names that match the pattern 'git*'.

## PARAMETERS

### -Catalog

The name or wildcard pattern of the remote catalog registration to retrieve.

The default value is '*' which returns all configured remote catalogs.

```yaml
Type: System.String
DefaultValue: '*'
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

### System.Object


## NOTES

- Remote catalog registrations are stored in the PSNotes configuration (for example, in the note store config file).
- If the PSNotes store is not initialized or no remote catalogs are configured, an empty array is returned.
- See also: Import-RemoteCatalog, Remove-RemoteCatalog


## RELATED LINKS

- [Remove-RemoteCatalog
Import-RemoteCatalog]()
