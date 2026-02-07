---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# ConvertTo-Splatting

## SYNOPSIS

Use to convert an existing PowerShell command to splatting

## SYNTAX

### string

```
ConvertTo-Splatting [[-Command <String>]] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### scriptblock

```
ConvertTo-Splatting [[-ScriptBlock <ScriptBlock>]] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick.
This function excepts any command as a string or a scriptblock and will convert the existing parameters
to a hashtable and output the fully splatted command for you.


## EXAMPLES

### Example 1: EXAMPLE 1

```
$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
'@
ConvertTo-Splatting $splatme
```

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





### Example 2: EXAMPLE 2

```
$splatme = {
    Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
}
ConvertTo-Splatting $splatme
```

Converts the scriptblock splatme to splatting

--- Output ----
$CopyItemParam = @{
        Path        = "test.txt"
        Destination = "test2.txt"
        WhatIf      = $true
}
Copy-Item @CopyItemParam





### Example 3: EXAMPLE 3

```
$splatme = {
    Get-AzVM `
        -ResourceGroupName "ResourceGroup11" `
        -Name "VirtualMachine07" `
        -Status
}
ConvertTo-Splatting $splatme
```

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
Type: String
Parameter Sets: string
Aliases: 
Accepted values: 

Required: True (None) False (string)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ScriptBlock

The command scriptblock you want to convert to using splatting

```yaml
Type: ScriptBlock
Parameter Sets: scriptblock
Aliases: 
Accepted values: 

Required: True (None) False (scriptblock)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

about_Splatting - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting


## RELATED LINKS

Fill Related Links Here

