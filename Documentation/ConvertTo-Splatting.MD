﻿# ConvertTo-Splatting

<a name="ConvertTo-Splatting"></a>
## ConvertTo-Splatting

![ConvertTo-Splatting01](media/ConvertTo-Splatting01.png)

### Synopsis
Use to convert an existing PowerShell command to splatting
### Description
Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick.
This function excepts any command as a string or a scriptblock and will convert the existing parameters
to a hashtable and output the fully splatted command for you.

### Syntax
```powershell
ConvertTo-Splatting [[-Command] <string>] [<CommonParameters>]

ConvertTo-Splatting [[-ScriptBlock] <scriptblock>] [<CommonParameters>]
```
### Parameters
#### Command &lt;String&gt;
    The command string you want to convert to using splatting
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### ScriptBlock &lt;ScriptBlock&gt;
    The command scriptblock you want to convert to using splatting
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Converts the string splatme to splatting
```powershell
$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = 
"xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
'@
ConvertTo-Splatting $splatme
```
###### Output
```
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
```
#### Example 2: Converts the scriptblock splatme to splatting
```powershell
$splatme = {
Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
}
ConvertTo-Splatting $splatme
```
###### Output
```
$CopyItemParam = @{
        Path        = "test.txt"
        Destination = "test2.txt"
        WhatIf      = $true
}
Copy-Item @CopyItemParam
```
#### Example 3: Removed backticks and converts the scriptblock splatme to splatting
```powershell
$splatme = {
Get-AzVM `
        -ResourceGroupName "ResourceGroup11" `
        -Name "VirtualMachine07" `
        -Status
}
ConvertTo-Splatting $splatme
```
###### Output
```
$GetAzVMParam = @{
    ResourceGroupName = "ResourceGroup11"
    Name              = "VirtualMachine07"
    Status            = $true
}
Get-AzVM @GetAzVMParam
```
