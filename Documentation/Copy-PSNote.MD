# Copy-PSNote

<a name="Copy-PSNote"></a>
## Copy-PSNote
### Synopsis
Use to display a list of notes in a selectable menu so you can choose which to copy to your clipboard
### Description
Allows you to search for snippets by name or by tag. You can also search all 
properties by using the SearchString parameter. Search results are displayed
in a selectable menu and you are prompted to select which one you want to 
add to your clipboard.

### Syntax
```powershell
Copy-PSNote [[-Note] <string>] [-Tag <string>] [<CommonParameters>]

Copy-PSNote [[-SearchString] <string>] [<CommonParameters>]
```
### Parameters
#### Note &lt;String&gt;
    The note you want to return. Accepts wildcards
    
    Required?                    false
    Position?                    1
    Default value                *
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Tag &lt;String&gt;
    The tag of the note(s) you want to return.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### SearchString &lt;String&gt;
    Use to search for text in the note&#39;s name, details, snippet, alias, and tags
    
    Required?                    false
    Position?                    1
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Returns a menu with all notes
```powershell
Copy-PSNote
```

#### Example 2: Returns a menu with the note creds
```powershell
Copy-PSNote -Name 'creds'
```

#### Example 3: Returns a menu with all notes that start with cred
```powershell
Copy-PSNote -Name 'cred*'
```

#### Example 4: Returns a menu with all notes with the tag 'AD'
```powershell
Copy-PSNote -tag 'AD'
```

#### Example 5: Returns a menu with all notes with user in the name and the tag 'AD'
```powershell
Copy-PSNote -Name '*user*' -tag 'AD'
```

#### Example 6: Returns a menu with all notes with the word day in the name, details, snippet text, alias, or tags
```powershell
Copy-PSNote -SearchString 'day'
```

