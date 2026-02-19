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

Gets configured remote catalogs.

## SYNTAX

### __AllParameterSets

```
Get-RemoteCatalog [[-Catalog] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Retrieves one or more remote catalogs from the note store configuration.

Remote catalogs are external sources used to import notes from other locations.

## EXAMPLES

### EXAMPLE 1

Get-RemoteCatalog
Returns all configured remote catalogs.

### EXAMPLE 2

Get-RemoteCatalog -Catalog 'github'
Returns the remote catalog named 'github'.

### EXAMPLE 3

Get-RemoteCatalog -Catalog 'git*'
Returns all remote catalogs matching the pattern 'git*'.

## PARAMETERS

### -Catalog

The name or wildcard pattern of the catalog to retrieve.

Supports wildcards (e.g., 'git*' to match 'github', 'gitlab', etc.).
Default value is '*' which returns all configured remote catalogs.

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
Returns remote catalog configuration objects or an empty array if no catalogs are configured.

{{ Fill in the Description }}

## NOTES

This cmdlet requires the PSNotes module to be initialized with remote catalogs configured.


## RELATED LINKS

- [Import-RemoteCatalog
Remove-RemoteCatalog]()
