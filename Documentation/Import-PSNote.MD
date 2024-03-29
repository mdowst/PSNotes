# Import-PSNote

<a name="Import-PSNote"></a>
## Import-PSNote
### Synopsis
Use to import a PSNotes JSON fiile
### Description
Allows you to import shared PSNotes JSON files to your local notes. They can be imported to your personal
store, or they can be imported to a seperate file.

### Syntax
```powershell
Import-PSNote [-Path] <string> [[-Catalog] <string>] [<CommonParameters>]
```
### Parameters
#### Path &lt;String&gt;
    The path to the PSNotes JSON file to export to.
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Catalog &lt;String&gt;
    Use to output snippets to a seperate file stored in the folder %APPDATA%\PSNotes.
    Useful for when you want to share different snippet types.
    
    Required?                    false
    Position?                    2
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Imports the contents of the file MyPSNotes.json and saves it to your personal PSNotes.json file
```powershell
Import-PSNote -Path C:\Import\MyPSNotes.json
```

#### Example 2: Imports the contents of the file MyPSNotes.json and saves it to the file ADNotes.json in the folder %APPDATA%\PSNotes
```powershell
Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'
```

