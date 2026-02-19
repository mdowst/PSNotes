---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: ConvertTo-Splatting
---

# ConvertTo-Splatting

## SYNOPSIS

Converts an existing PowerShell command into a splatting hashtable and splatted command.

## SYNTAX

### string

```
ConvertTo-Splatting [[-Command] <string>] [<CommonParameters>]
```

### scriptblock

```
ConvertTo-Splatting [[-ScriptBlock] <scriptblock>] [<CommonParameters>]
```

## DESCRIPTION

ConvertTo-Splatting takes a PowerShell command provided as a string or script block and rewrites it
into a splatting-friendly format.
It parses the command, identifies the command name and parameters,
and produces:

- A hashtable assignment (for example, $GetItemParam = @{ ...
})
- A command invocation that uses splatting (for example, Get-Item @GetItemParam)

This is useful for refactoring long command lines into a clearer, more maintainable structure, and for
turning backtick-continued commands into a single normalized form.

## EXAMPLES

### EXAMPLE 1

```powershell
$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx"} `
    -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
'@
ConvertTo-Splatting $splatme
```

Creates a parameter hashtable and a splatted Set-AzVMExtension call.

### EXAMPLE 2

```powershell
$splatme = { Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf }
ConvertTo-Splatting $splatme
```

Converts a script block command into a hashtable and a splatted Copy-Item call.
Switch parameters are
represented as $true.

### EXAMPLE 3

```powershell
$splatme = {
    Get-AzVM `
        -ResourceGroupName "ResourceGroup11" `
        -Name "VirtualMachine07" `
        -Status
}
ConvertTo-Splatting $splatme
```

Normalizes backtick line continuations and converts the command to splatting.

## PARAMETERS

### -Command

The command text to convert to splatting.
Provide a full command line as a string.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: string
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptBlock

The command to convert to splatting, provided as a script block.
The script block is converted to text
and normalized prior to parsing.

```yaml
Type: System.Management.Automation.ScriptBlock
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: scriptblock
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

## NOTES

- If the command starts with a variable assignment, the variable(s) are preserved as part of the parsed command.
- The hashtable variable name is derived from the command name (for example, Get-Item -> $GetItemParam).
If that
  name conflicts with an existing constant variable, a fallback name is used.
- For background on splatting, see:
  about_Splatting - https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_splatting


## RELATED LINKS


