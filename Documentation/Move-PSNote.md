---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Move-PSNote

## SYNOPSIS

Moves a note to a different catalog.

## SYNTAX

### __AllParameterSets

```
Move-PSNote [-InputObject] <PSNote> [-DestinationCatalog] <String> [-Confirm] [-Force] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION

Moves a note from its current catalog to another catalog.
Supports
confirmation prompts via ShouldProcess.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work'
Moves the note named 'Install-Module' to the 'Work' catalog.
```







### Example 2: EXAMPLE 2

```
Get-PSNote -Catalog 'Personal' | Move-PSNote -DestinationCatalog 'Archive' -Force
Moves all notes from 'Personal' to 'Archive', overwriting duplicates.
```







### Example 3: EXAMPLE 3

```
Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work' -PassThru
Moves the note and returns the moved note object.
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

### -DestinationCatalog

The target catalog name to move the note to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Force

Overwrites the destination note if it already exists.

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

The note to move.
Accepts pipeline input from Get-PSNote.

```yaml
Type: PSNote
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

Returns the moved note object.

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

### PSNote
Returns note objects when -PassThru is specified; otherwise returns nothing.


## NOTES



## RELATED LINKS

[Get-PSNote
Set-PSNote
Remove-PSNote] ()

