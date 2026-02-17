---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Invoke-PSNote

## SYNOPSIS

Use to display a list of notes in a selectable menu so you can choose which to run

## SYNTAX

### Note (Default)

```
Invoke-PSNote [-Note] <PSNote> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Allows you to search for snippets by name or by tag.
You can also search all 
properties by using the SearchString parameter.
Search results are displayed
in a selectable menu and you are prompted to select which one you want to run.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Invoke-PSNote
```

Returns a menu with all notes





### Example 2: EXAMPLE 2

```
Invoke-PSNote -Name 'creds'
```

Returns a menu with the note creds





### Example 3: EXAMPLE 3

```
Invoke-PSNote -Name 'cred*'
```

Returns a menu with all notes that start with cred





### Example 4: EXAMPLE 4

```
Invoke-PSNote -tag 'AD'
```

Returns a menu with all notes with the tag 'AD'





### Example 5: EXAMPLE 5

```
Invoke-PSNote -Name '*user*' -tag 'AD'
```

Returns a menu with all notes with user in the name and the tag 'AD'





### Example 6: EXAMPLE 6

```
Invoke-PSNote -SearchString 'day'
```

Returns a menu with all notes with the word day in the name, details, snippet text, alias, or tags






## PARAMETERS

### -Note

The note you want to run.
Accepts wildcards

```yaml
Type: PSNote
Parameter Sets: Note
Aliases: 
Accepted values: 

Required: True (Note) False (None)
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

[] (https://github.com/mdowst/PSNotes)

