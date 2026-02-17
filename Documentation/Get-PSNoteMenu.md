---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Get-PSNoteMenu

## SYNOPSIS

Displays an interactive, paged menu of PSNotes and lets the user pick one by number.

## SYNTAX

### __AllParameterSets

```
Get-PSNoteMenu [[-InputObject <Object>]] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Renders notes in a numbered, multi-column list sized to the current console window.
Prompts for a number to select a note, or Enter to advance to the next page.

Output:
  - Returns the selected PSNote object (or $null if quit / nothing selected).

Assumptions:
  - Get-PSNote returns objects with (at least) Catalog, Alias, and Note properties.
    (If Catalog is missing/empty, it displays "Default".)


## EXAMPLES

### Example 1: EXAMPLE 1

```
$note = Get-PSNoteMenu
```








## PARAMETERS

### -InputObject

{{ Fill InputObject Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: True
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



## RELATED LINKS

Fill Related Links Here

