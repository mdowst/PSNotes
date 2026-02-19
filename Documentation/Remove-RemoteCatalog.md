---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Remove-RemoteCatalog
---

# Remove-RemoteCatalog

## SYNOPSIS

Removes a remote catalog registration from PSNotes.

## SYNTAX

### __AllParameterSets

```
Remove-RemoteCatalog [-InputObject] <RemoteCatalogSource> [-ConvertToLocal] [-Force] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Remove-RemoteCatalog unregisters one or more remote catalog sources from the PSNotes configuration.

By default, this cmdlet removes only the remote registration and leaves any previously imported
local catalog content unchanged.

If -ConvertToLocal is specified, the cached remote catalog is converted into a local catalog
before removing the remote registration.
This allows you to keep the notes while removing the
remote dependency.

This cmdlet supports pipeline input from Get-RemoteCatalog and implements ShouldProcess,
allowing the use of -WhatIf and -Confirm.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-RemoteCatalog
```

Lists all registered remote catalogs.

### EXAMPLE 2

```powershell
Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog
```

Removes the 'github' remote catalog registration.

### EXAMPLE 3

```powershell
Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog -ConvertToLocal
```

Converts the cached remote catalog into a local catalog and removes the remote registration.

### EXAMPLE 4

```powershell
Get-RemoteCatalog | Remove-RemoteCatalog -Force
```

Removes all remote catalog registrations without prompting.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
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

### -ConvertToLocal

Converts the cached remote catalog into a local catalog before removing the remote registration.

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

Suppresses confirmation prompts when removing a remote catalog registration.

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

### -InputObject

A remote catalog object to remove.
Accepts pipeline input from Get-RemoteCatalog.

```yaml
Type: RemoteCatalogSource
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PassThru

Returns the removed (or converted) catalog object.

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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### RemoteCatalogSource


## OUTPUTS

### System.Object


## NOTES

- Supports -WhatIf and -Confirm through ShouldProcess.
- Removing a remote catalog does not delete local catalogs unless explicitly converted or managed separately.
- See also: Get-RemoteCatalog, Import-RemoteCatalog


## RELATED LINKS

- [Get-RemoteCatalog
Import-RemoteCatalog]()
