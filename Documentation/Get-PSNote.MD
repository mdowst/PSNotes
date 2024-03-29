# Get-PSNote

<a name="Get-PSNote"></a>
## Get-PSNote
### Synopsis
Use to search for or list the different PSNotes
### Description
Allows you to search for snippets by name or by tag. You can also search all 
properties by using the SearchString parameter

### Syntax
```powershell
Get-PSNote [-Note <string>] [-Tag <string>] [-Copy] [-Run] [<CommonParameters>]

Get-PSNote [-SearchString <string>] [<CommonParameters>]
```
### Parameters
#### Note &lt;String&gt;
    The note you want to return. Accepts wildcards
    
    Required?                    false
    Position?                    named
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
#### Copy [&lt;SwitchParameter&gt;]
    If specfied the the Snippet will be copied to your clipboard
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Run [&lt;SwitchParameter&gt;]
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### SearchString &lt;String&gt;
    Use to search for text in the note&#39;s name, details, snippet, alias, and tags
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Returns all notes
```powershell
Get-PSNote
```

#### Example 2: Returns the note creds
```powershell
Get-PSNote -Name 'creds'
```

#### Example 3: Returns all notes that start with cred
```powershell
Get-PSNote -Name 'cred*'
```

#### Example 4: Returns all notes with the tag 'AD'
```powershell
Get-PSNote -tag 'AD'
```

#### Example 5: Returns all notes with user in the name and the tag 'AD'
```powershell
Get-PSNote -Name '*user*' -tag 'AD'
```

#### Example 6: Returns all notes with the word day in the name, details, snippet text, alias, or tags
```powershell
Get-PSNote -SearchString 'day'
```

