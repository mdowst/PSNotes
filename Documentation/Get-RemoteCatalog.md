---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Get-RemoteCatalog

## SYNOPSIS

Gets configured remote catalogs.

## SYNTAX

### __AllParameterSets

```
Get-RemoteCatalog [[-Catalog <String>]] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves one or more remote catalogs from the note store configuration.

Remote catalogs are external sources used to import notes from other locations.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-RemoteCatalog
Returns all configured remote catalogs.
```







### Example 2: EXAMPLE 2

```
Get-RemoteCatalog -Catalog 'github'
Returns the remote catalog named 'github'.
```







### Example 3: EXAMPLE 3

```
Get-RemoteCatalog -Catalog 'git*'
Returns all remote catalogs matching the pattern 'git*'.
```








## PARAMETERS

### -Catalog

The name or wildcard pattern of the catalog to retrieve.

Supports wildcards (e.g., 'git*' to match 'github', 'gitlab', etc.).
Default value is '*' which returns all configured remote catalogs.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object
Returns remote catalog configuration objects or an empty array if no catalogs are configured.


## NOTES

This cmdlet requires the PSNotes module to be initialized with remote catalogs configured.


## RELATED LINKS

[Import-RemoteCatalog
Remove-RemoteCatalog] ()

