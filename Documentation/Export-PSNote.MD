---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Export-PSNote

## SYNOPSIS

Export PSNotes to a JSON file

## SYNTAX

### Note (Default)

```
Export-PSNote -NoteObject <PSNote[]> -Path <String> [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Catalog

```
Export-PSNote -Catalog <String> -Path <String> [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Exports PSNotes to a JSON file for sharing or importing on another machine.
You can export notes by catalog or by piping PSNote objects into this command.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Export-PSNote -Catalog 'Default' -Path C:\Export\MyPSNotes.json
```

Exports all notes from the 'Default' catalog to a JSON file.





### Example 2: EXAMPLE 2

```
Get-PSNote -Tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json
```

Exports all notes with the tag 'AD' to the file SharedADNotes.json.





### Example 3: EXAMPLE 3

```
Get-PSNote -Note 'Cred*' -Catalog 'Work' | Export-PSNote -Path C:\Export\WorkCreds.json
```

Exports notes that match the name pattern from the 'Work' catalog.





### Example 4: EXAMPLE 4

```
Get-PSNote -SearchString 'token' | Export-PSNote -Path C:\Export\TokenNotes.json
```

Exports notes that match a search string.





### Example 5: EXAMPLE 5

```
Export-PSNote -Catalog 'Personal' -Path C:\Export\PersonalNotes.json -Force
```

Exports the 'Personal' catalog and overwrites the file if it exists.






## PARAMETERS

### -Catalog

The catalog name to export.
When specified, all notes from that catalog are exported.

```yaml
Type: String
Parameter Sets: Catalog
Aliases: 
Accepted values: 

Required: True (Catalog) False (None)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Force

Overwrite the output file if it already exists.

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

### -NoteObject

The PSNote objects you want to export.
Use Get-PSNote to build the object and pass it to the parameter
or use the pipeline to pass them in.

```yaml
Type: PSNote[]
Parameter Sets: Note
Aliases: 
Accepted values: 

Required: True (Note) False (None)
Position: Named
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Path

The path to the PSNotes JSON file to export to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: Named
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

