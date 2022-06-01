# Splatting Commands
There are two splatting commands included in the PSNotes module. There is ConvertTo-Splatting which will take an existing command and convert it to a splatting format. The other is Get-CommandSplatting. This will output the parameters for a command in splatting format, along with a set of variables for you to set the values with. 

* [ConvertTo-Splatting](#ConvertTo-Splatting)
* [Get-CommandSplatting](#Get-CommandSplatting)

## ConvertTo-Splatting
Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick. This function takes any command as a string or a scriptblock and will convert the existing parameters to a hashtable and output the fully splatted command for you.

##### Example 1: Pass a command as a ScriptBlock to convert it to splatting format
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

##### Example 2: Pass a command as a string to convert it to splatting format
```powershell
$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
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
##### Example 3: Removed backticks and converts the scriptblock splatme to splatting
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
[top](#splatting-commands)
## Get-CommandSplatting
This function output the parameters for a command in splatting format

##### Example 1: Get the default parameter set for a command
```powershell
Get-CommandSplatting -Command 'Get-Item'
```
###### Output
```
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
```

##### Example 2: List the available parameter sets for a command
```powershell
Get-CommandSplatting -Command 'Get-Item' -ListParameterSets
```
###### Output
```
ParameterSet : Path
IsDefault    : True
Parameters   : Path, Filter, Include, Exclude, Force, Credential, Stream

ParameterSet : LiteralPath
IsDefault    : False
Parameters   : LiteralPath, Filter, Include, Exclude, Force, Credential, Stream
```

##### Example 3: Get specific parameter set for a command
```powershell
Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath
```
###### Output
```
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
```

##### Example 4: Get all parameter sets for a command
```powershell
Get-CommandSplatting -Command 'Get-Item' -All
```
###### Output
```
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
```
[top](#splatting-commands)