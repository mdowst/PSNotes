# Export-PSNote

<a name="Export-PSNote"></a>
## Export-PSNote
### Synopsis
Use to export your PSNotes to copy to another machine or share with others
### Description
Allows you to export your PSNotes to a JSON file, that can then be imported
to another machine or by other users.

### Syntax
```powershell
Export-PSNote -NoteObject <PSNote[]> -Path <string> [-Append] [<CommonParameters>]

Export-PSNote -Path <string> [-All] [-Append] [<CommonParameters>]
```
### Parameters
#### NoteObject &lt;PSNote[]&gt;
    The PSNote objects you want to export. Use Get-PSNote to build the object and pass it to the parameter
    or use a pipeline to pass it.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       true (ByValue)
    Accept wildcard characters?  false
#### All [&lt;SwitchParameter&gt;]
    Export all PSNotes
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Path &lt;String&gt;
    The path to the PSNotes JSON file to export to.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Append [&lt;SwitchParameter&gt;]
    Use to append the output file. Default is to overwrite.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Exportall notes to a JSON file.
```powershell
Export-PSNote -All -Path C:\Export\MyPSNotes.json
```

#### Example 2: Exports all notes with the tag 'AD' to the file SharedADNotes.json
```powershell
Get-PSNote -tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json
```

