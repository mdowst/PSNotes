---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Remove-PSNote

## SYNOPSIS

Remove one or more PSNotes from the note store.

## SYNTAX

### Note (Default)

```
Remove-PSNote [-Catalog <String[]>] [-Confirm] [-Force] [-Note <String>] [-ProgressAction <ActionPreference>] [-Tag <String>] [-WhatIf] [<CommonParameters>]
```

### ByObject

```
Remove-PSNote -InputObject <Object> [-Confirm] [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [<CommonParameters>]
```

### Search

```
Remove-PSNote -SearchString <String> [-Catalog <String[]>] [-Confirm] [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION

You can remove notes by piping results from Get-PSNote, or by using the same
discovery parameters (Note/Tag/Catalog/SearchString) to select notes to remove.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-PSNote -SearchString 'cred' -Catalog 'Work*' | Remove-PSNote
```

Removes notes matched by search string from catalogs that start with 'Work'.





### Example 2: EXAMPLE 2

```
Remove-PSNote -Note 'cred*' -Catalog 'Default'
```

Removes notes with names starting with 'cred' from the Default catalog.





### Example 3: EXAMPLE 3

```
Remove-PSNote -SearchString 'token' -Catalog 'Work*','Personal*' -Force
```

Removes notes matching 'token' in the Work and Personal catalogs without confirmation.





### Example 4: EXAMPLE 4

```
Get-PSNote -Tag 'deprecated' | Remove-PSNote -Force
```

Removes all notes tagged 'deprecated' via pipeline without confirmation.






## PARAMETERS

### -Catalog

Filter by catalog name (wildcards supported; accepts multiple values).

```yaml
Type: String[]
Parameter Sets: Search, Note
Aliases: 
Accepted values: 

Required: True (None) False (Search, Note)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

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

### -Force

Suppress confirmation prompts (still honors -WhatIf).

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

Pipeline input (typically from Get-PSNote).

```yaml
Type: Object
Parameter Sets: ByObject
Aliases: 
Accepted values: 

Required: True (ByObject) False (None)
Position: Named
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Note

Note name pattern (wildcards supported).
Defaults to '*'.

```yaml
Type: String
Parameter Sets: Note
Aliases: 
Accepted values: 

Required: True (None) False (Note)
Position: Named
Default value: *
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

### -SearchString

Free-text search across Note/Alias/Details/Snippet/Tags.

```yaml
Type: String
Parameter Sets: Search
Aliases: 
Accepted values: 

Required: True (Search) False (None)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Tag

Filter by tag (exact match, consistent with Get-PSNote).

```yaml
Type: String
Parameter Sets: Note
Aliases: 
Accepted values: 

Required: True (None) False (Note)
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

## NOTES



## RELATED LINKS

[] (https://github.com/mdowst/PSNotes)

