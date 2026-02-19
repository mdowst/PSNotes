---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Import-RemoteCatalog
---

# Import-RemoteCatalog

## SYNOPSIS

Registers a remote PSNotes catalog or imports it as a local catalog.

## SYNTAX

### __AllParameterSets

```
Import-RemoteCatalog [-Name] <string> [-Url] <string> [-AsLocal] [-Force] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION

Import-RemoteCatalog adds a remote catalog source to PSNotes or downloads it immediately as a local
catalog.

By default, the cmdlet registers the remote catalog URL in the PSNotes store under the provided name.
This allows you to keep the catalog “linked” for future imports.

When -AsLocal is specified, the remote catalog is downloaded immediately and saved as a LOCAL catalog.
In this mode, the URL is not registered as a remote source.
Use -Force to overwrite an existing local
catalog with the same name.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json'
```

Registers the remote catalog URL for later use.

### EXAMPLE 2

```powershell
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal
```

Downloads the remote catalog immediately and creates a local catalog.
The URL is not registered.

### EXAMPLE 3

```powershell
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal -Force -PassThru
```

Overwrites the existing local catalog and returns the created catalog object.

## PARAMETERS

### -AsLocal

Downloads the remote catalog immediately and creates a LOCAL catalog.

When specified, the remote catalog URL is not registered.

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

### -Force

Only applies to -AsLocal.

Overwrites the local catalog if it already exists.

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

### -Name

The name to register for the remote catalog (or the name of the local catalog to create when -AsLocal is used).

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

### -PassThru

Returns the created or registered catalog object.

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

### -Url

The URL of the remote catalog JSON.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
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

- -AsLocal creates a local catalog immediately and does not register the URL as a remote catalog.
- Use Get-RemoteCatalog to view registered remote sources.
- See also: Get-RemoteCatalog, Remove-RemoteCatalog


## RELATED LINKS

- [Get-RemoteCatalog
Remove-RemoteCatalog]()
