---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Get-PSNote

## SYNOPSIS

Search for or list PSNotes

## SYNTAX

### Note (Default)

```
Get-PSNote [-Catalog <String[]>] [-Copy] [-Note <String>] [-ProgressAction <ActionPreference>] [-Run] [-Tag <String>] [<CommonParameters>]
```

### Search

```
Get-PSNote [-Catalog <String[]>] [-ProgressAction <ActionPreference>] [-Run] [-SearchString <String>] [<CommonParameters>]
```

## DESCRIPTION

Searches notes by name, tag, or text across all note properties.
You can also
filter by catalog and optionally copy or run the returned snippet.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-PSNote
```

Returns all notes.





### Example 2: EXAMPLE 2

```
Get-PSNote -Note 'Creds'
```

Returns the note named 'Creds'.





### Example 3: EXAMPLE 3

```
Get-PSNote -Note 'Cred*'
```

Returns all notes with names that start with 'Cred'.





### Example 4: EXAMPLE 4

```
Get-PSNote -Tag 'AD'
```

Returns all notes with the tag 'AD'.





### Example 5: EXAMPLE 5

```
Get-PSNote -Note '*User*' -Tag 'AD'
```

Returns notes with 'User' in the name and the tag 'AD'.





### Example 6: EXAMPLE 6

```
Get-PSNote -SearchString 'day'
```

Returns notes where 'day' appears in the name, details, snippet, alias, or tags.





### Example 7: EXAMPLE 7

```
Get-PSNote -Catalog 'Default'
```

Returns all notes in the Default catalog.





### Example 8: EXAMPLE 8

```
Get-PSNote -SearchString 'day' -Catalog 'Work*','Personal*'
```

Searches only within the matching catalogs.





### Example 9: EXAMPLE 9

```
Get-PSNote -Note 'CpuUsage' -Copy
```

Copies the snippet for the selected note to the clipboard.





### Example 10: EXAMPLE 10

```
Get-PSNote -SearchString 'token' -Run
```

Runs the selected note; prompts to choose if multiple notes match.






## PARAMETERS

### -Catalog

Filter notes by catalog name.
Accepts wildcards and multiple values.

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

### -Copy

Copy the selected snippet to the clipboard.

```yaml
Type: SwitchParameter
Parameter Sets: Note
Aliases: 
Accepted values: 

Required: True (None) False (Note)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Note

The note name to return.
Accepts wildcards.

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

### -Run

Run the selected snippet via Invoke-PSNote.

```yaml
Type: SwitchParameter
Parameter Sets: Search, Note
Aliases: 
Accepted values: 

Required: True (None) False (Search, Note)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -SearchString

Search for text in the note's name, details, snippet, alias, or tags.

```yaml
Type: String
Parameter Sets: Search
Aliases: 
Accepted values: 

Required: True (None) False (Search)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Tag

Return notes that contain the specified tag.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

[] (https://github.com/mdowst/PSNotes)

