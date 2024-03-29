﻿# Get-CommandSplatting

<a name="Get-CommandSplatting"></a>
## Get-CommandSplatting

![Get-CommandSplatting01](media/Get-CommandSplatting01.png)

### Synopsis
Use to output the parameters for a command in splatting format
### Description
Use to output the parameters for a command in splatting format

### Syntax
```powershell
Get-CommandSplatting [-Command] <string> [[-ParameterSet] <string>] [-IncludeCommon] [-Copy] [<CommonParameters>]

Get-CommandSplatting [-Command] <string> [-ListParameterSets] [-IncludeCommon] [-Copy] [<CommonParameters>]

Get-CommandSplatting [-Command] <string> [-All] [-IncludeCommon] [-Copy] [<CommonParameters>]
```
### Parameters
#### Command &lt;String&gt;
    The command to get the parameters for
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### ParameterSet &lt;String&gt;
    Use to specify a specific parameter set. Use the -ListParameterSets to get a quick
    view of all the different Parameter Set names.
    
    Required?                    false
    Position?                    2
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### ListParameterSets [&lt;SwitchParameter&gt;]
    Use to list the different Parameter Sets available for the command. Output is shortened 
    to only show the names. Use -All to return splatting for all parameter sets.
    
    Required?                    false
    Position?                    2
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### All [&lt;SwitchParameter&gt;]
    Use to return full splatting for all parameter sets
    
    Required?                    false
    Position?                    2
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### IncludeCommon [&lt;SwitchParameter&gt;]
    Use to include the PowerShell common parameters in the splatting output. (e.g. Verbose, ErrorAction, etc.)
    
    Required?                    false
    Position?                    3
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Copy [&lt;SwitchParameter&gt;]
    
    Required?                    false
    Position?                    4
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Get the default parameter set for a command
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
#### Example 2: List the available parameter sets for a command
```powershell
Get-CommandSplatting -Command 'Get-Item' -ListParameterSets
```
###### Output
```
ParameterSet : Path
IsDefault    : True
Parameters   : Path, Filter, Include, Exclude, Force, Credential, Stream
```
#### Example 3: Get specific parameter set for a command
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
#### Example 4: Get all parameter sets for a command
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
