---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-CommandSplatting
---

# Get-CommandSplatting

## SYNOPSIS

Use to output the parameters for a command in splatting format

## SYNTAX

### ParameterSet (Default)

```
Get-CommandSplatting [-Command] <string> [[-ParameterSet] <string>] [-IncludeCommon] [-Copy]
 [<CommonParameters>]
```

### ListParameterSets

```
Get-CommandSplatting [-Command] <string> [-ListParameterSets] [-IncludeCommon] [-Copy]
 [<CommonParameters>]
```

### All

```
Get-CommandSplatting [-Command] <string> [-All] [-IncludeCommon] [-Copy] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Use to output the parameters for a command in splatting format

## EXAMPLES

### EXAMPLE 1

Get-CommandSplatting -Command 'Get-Item'

Get the default parameter set for a command

--- Output ----
Name      : Path
IsDefault : True
SetBlock :
        [string[]]$Path = ''
        [string]$Filter = ''
        [string[]]$Include = ''
        [string[]]$Exclude = ''
        [Boolean]$Force = $false # Switch
        [pscredential]$Credential = ''
        [string[]]$Stream = ''
HashBlock :
        $Item = @{
                Path       = $Path       #Required
                Filter     = $Filter
                Include    = $Include
                Exclude    = $Exclude
                Force      = $Force
                Credential = $Credential
                Stream     = $Stream
        }
        Get-Item @Item

### EXAMPLE 2

Get-CommandSplatting -Command 'Get-Item' -ListParameterSets

List the available parameter sets for a command

--- Output ----
ParameterSet : Path
IsDefault    : True
Parameters   : Path, Filter, Include, Exclude, Force, Credential, Stream

ParameterSet : LiteralPath
IsDefault    : False
Parameters   : LiteralPath, Filter, Include, Exclude, Force, Credential, Stream

### EXAMPLE 3

Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath

Get specific parameter set for a command

--- Output ----
ParameterSet : LiteralPath
IsDefault    : False
SetBlock     :
        [string[]]$LiteralPath = '' 
        [string]$Filter = '' 
        [string[]]$Include = ''
        [string[]]$Exclude = ''
        [Boolean]$Force = $false # Switch
        [pscredential]$Credential = ''
        [string[]]$Stream = ''
HashBlock  :
        $ItemLiteralPath = @{
                LiteralPath = $LiteralPath #Required
                Filter      = $Filter
                Include     = $Include
                Exclude     = $Exclude
                Force       = $Force
                Credential  = $Credential
                Stream      = $Stream
        }
        Get-Item @ItemLiteralPath

### EXAMPLE 4

Get-CommandSplatting -Command 'Get-Item' -All

Get all parameter sets for a command

--- Output ----
ParameterSet : Path
IsDefault    : True
SetBlock     :
        [string[]]$Path = '' 
        [string]$Filter = '' 
        [string[]]$Include = '' 
        [string[]]$Exclude = '' 
        [Boolean]$Force = $false # Switch 
        [pscredential]$Credential = '' 
        [string[]]$Stream = ''
HashBlock  :
        $ItemPath = @{ 
                Path       = $Path       #Required 
                Filter     = $Filter 
                Include    = $Include 
                Exclude    = $Exclude
                Force      = $Force
                Credential = $Credential
                Stream     = $Stream
        }
        Get-Item @ItemPath
ParameterSet : LiteralPath
IsDefault    : False
SetBlock     :
        [string[]]$LiteralPath = ''
        [string]$Filter = ''
        [string[]]$Include = ''
        [string[]]$Exclude = ''
        [Boolean]$Force = $false # Switch
        [pscredential]$Credential = ''
        [string[]]$Stream = ''
HashBlock  :
        $ItemLiteralPath = @{
                LiteralPath = $LiteralPath #Required
                Filter      = $Filter
                Include     = $Include
                Exclude     = $Exclude
                Force       = $Force
                Credential  = $Credential
                Stream      = $Stream
        }
        Get-Item @ItemLiteralPath

## PARAMETERS

### -All

Use to return full splatting for all parameter sets

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: All
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Command

The command to get the parameters for

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

### -Copy

{{ Fill Copy Description }}

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IncludeCommon

Use to include the PowerShell common parameters in the splatting output.
(e.g.
Verbose, ErrorAction, etc.)

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
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

### -ListParameterSets

Use to list the different Parameter Sets available for the command.
Output is shortened 
to only show the names.
Use -All to return splatting for all parameter sets.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ListParameterSets
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ParameterSet

Use to specify a specific parameter set.
Use the -ListParameterSets to get a quick
view of all the different Parameter Set names.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ParameterSet
  Position: 1
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

General notes


## RELATED LINKS

{{ Fill in the related links here }}

