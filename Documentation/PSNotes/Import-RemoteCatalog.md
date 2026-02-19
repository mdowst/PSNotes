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

Registers or imports a remote catalog.

## SYNTAX

### __AllParameterSets

```
Import-RemoteCatalog [-Name] <string> [-Url] <string> [-AsLocal] [-Force] [-PassThru]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Registers a remote catalog URL in the note store, or downloads it immediately
as a local catalog when -AsLocal is specified.

## EXAMPLES

### EXAMPLE 1

Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json'
Registers the remote catalog URL for later use.

### EXAMPLE 2

Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal
Downloads the remote catalog and creates a local catalog.

### EXAMPLE 3

Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal -Force -PassThru
Overwrites the local catalog and returns the created catalog object.

## PARAMETERS

### -AsLocal

Downloads the remote catalog immediately and creates a LOCAL catalog.
When specified, the URL is not registered.

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

The name to register for the remote catalog.

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
Returns catalog objects when -PassThru is specified; otherwise returns nothing.

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

- [Get-RemoteCatalog
Remove-RemoteCatalog]()
