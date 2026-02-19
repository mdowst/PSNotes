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

Use to convert an existing PowerShell command to splatting

## SYNTAX

### string

```
ConvertTo-Splatting [[-Command] <string>] [<CommonParameters>]
```

### scriptblock

```
ConvertTo-Splatting [[-ScriptBlock] <scriptblock>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick.
This function excepts any command as a string or a scriptblock and will convert the existing parameters
to a hashtable and output the fully splatted command for you.

## EXAMPLES

### EXAMPLE 1

$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
'@
ConvertTo-Splatting $splatme

Converts the string splatme to splatting

--- Output ----
$SetAzVMExtensionParam = @{
        ExtensionName      = "MicrosoftMonitoringAgent"
        ResourceGroupName  = "rg-xxxx"
        VMName             = "vm-xxxx"
        Publisher          = "Microsoft.EnterpriseCloud.Monitoring"
        ExtensionType      = "MicrosoftMonitoringAgent"
        TypeHandlerVersion = "1.0"
        Settings           = @{ "workspaceId" = "xxxx" }
        ProtectedSettings  = @{ "workspaceKey" = "xxxx" }
        Location           = "uksouth"
}
Set-AzVMExtension @SetAzVMExtensionParam

### EXAMPLE 2

$splatme = {
    Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
}
ConvertTo-Splatting $splatme

Converts the scriptblock splatme to splatting

--- Output ----
$CopyItemParam = @{
        Path        = "test.txt"
        Destination = "test2.txt"
        WhatIf      = $true
}
Copy-Item @CopyItemParam

### EXAMPLE 3

$splatme = {
    Get-AzVM `
        -ResourceGroupName "ResourceGroup11" `
        -Name "VirtualMachine07" `
        -Status
}
ConvertTo-Splatting $splatme

Removed backticks and converts the scriptblock splatme to splatting

--- Output ----
$GetAzVMParam = @{
    ResourceGroupName = "ResourceGroup11"
    Name              = "VirtualMachine07"
    Status            = $true
}
Get-AzVM @GetAzVMParam

## PARAMETERS

### -Command

The command string you want to convert to using splatting

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

The command scriptblock you want to convert to using splatting

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

about_Splatting - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting


## RELATED LINKS

{{ Fill in the related links here }}

