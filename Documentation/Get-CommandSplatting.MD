---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Get-CommandSplatting

## SYNOPSIS

Use to output the parameters for a command in splatting format

## SYNTAX

### ParameterSet (Default)

```
Get-CommandSplatting [-Command] <String> [[-ParameterSet <String>]] [-IncludeCommon] [-Copy] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ListParameterSets

```
Get-CommandSplatting [-Command] <String> [-ListParameterSets] [-IncludeCommon] [-Copy] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All

```
Get-CommandSplatting [-Command] <String> [-All] [-IncludeCommon] [-Copy] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Use to output the parameters for a command in splatting format


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-CommandSplatting -Command 'Get-Item'
```

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





### Example 2: EXAMPLE 2

```
Get-CommandSplatting -Command 'Get-Item' -ListParameterSets
```

List the available parameter sets for a command

--- Output ----
ParameterSet : Path
IsDefault    : True
Parameters   : Path, Filter, Include, Exclude, Force, Credential, Stream

ParameterSet : LiteralPath
IsDefault    : False
Parameters   : LiteralPath, Filter, Include, Exclude, Force, Credential, Stream





### Example 3: EXAMPLE 3

```
Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath
```

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





### Example 4: EXAMPLE 4

```
Get-CommandSplatting -Command 'Get-Item' -All
```

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
Type: SwitchParameter
Parameter Sets: All
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Command

The command to get the parameters for

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Copy

{{ Fill Copy Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -IncludeCommon

Use to include the PowerShell common parameters in the splatting output.
(e.g.
Verbose, ErrorAction, etc.)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ListParameterSets

Use to list the different Parameter Sets available for the command.
Output is shortened 
to only show the names.
Use -All to return splatting for all parameter sets.

```yaml
Type: SwitchParameter
Parameter Sets: ListParameterSets
Aliases: 
Accepted values: 

Required: True (None) False (ListParameterSets)
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ParameterSet

Use to specify a specific parameter set.
Use the -ListParameterSets to get a quick
view of all the different Parameter Set names.

```yaml
Type: String
Parameter Sets: ParameterSet
Aliases: 
Accepted values: 

Required: True (None) False (ParameterSet)
Position: 1
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

General notes


## RELATED LINKS

Fill Related Links Here

