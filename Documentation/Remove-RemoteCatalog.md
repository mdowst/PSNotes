---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Remove-RemoteCatalog

## SYNOPSIS

Removes a remote catalog registration.

## SYNTAX

### __AllParameterSets

```
Remove-RemoteCatalog [-InputObject] <RemoteCatalogSource> [-Confirm] [-ConvertToLocal] [-Force] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION

Removes a registered remote catalog.
Optionally converts the cached remote
catalog to a local catalog before removing the registration.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog
Removes the remote catalog registration for 'github'.
```







### Example 2: EXAMPLE 2

```
Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog -ConvertToLocal
Converts the cached remote catalog to a local catalog and removes the
remote registration.
```







### Example 3: EXAMPLE 3

```
Get-RemoteCatalog | Remove-RemoteCatalog -Force -PassThru
Removes all remote catalogs and returns the removed objects.
```








## PARAMETERS

### -Confirm

{{ Fill Confirm Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ConvertToLocal

Converts the cached remote catalog into a local catalog before removing
the remote registration.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Force

Forces removal or conversion if the target already exists.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -InputObject

The remote catalog object to remove.
Accepts pipeline input from
Get-RemoteCatalog.

```yaml
Type: RemoteCatalogSource
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -PassThru

Returns the removed catalog object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
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

### -WhatIf

{{ Fill WhatIf Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi
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

## OUTPUTS

### System.Object
Returns catalog objects when -PassThru is specified; otherwise returns nothing.


## NOTES



## RELATED LINKS

[Get-RemoteCatalog
Import-RemoteCatalog] ()

