# PSNotes

PSNotes is a PowerShell module that allows you to create your own custom snippet library, that you can use to reference commands you run often. Or ones you don't run often and need a reminder on. Snippets can either be executed directly, copied to your clipboard, or simply output to the display for you to do whatever you want with them. When you create a note, you assign an alias to it, so you can have an easy to remember keyword that you can then use to recall it. Notes can also be classified with tags, so you can easily search for them. 

* [Key Features](#key-features)
* [Getting Started](#getting-started)
    * [Install Instructions](#install-instructions)
    * [Output and Run Notes](#output-and-Run-Notes)
    * [Search Notes](#search-notes)
    * [Creating Notes](#Creating-Notes)
    * [Updating Notes](#updating-notes)
    * [Sharing Notes](#sharing-notes)

# Key Features

### Recall a command using a specific alias keyword
When you create a new note, you can define an alias that you can later use to display or run it.
![UnixTime Demo](Documentation/media/UnixTime.gif)

Perfect for long commands you need to run often.
![AzCon Demo](Documentation/media/AzCon.gif)

### Easily search your notes
You can assign tags to your notes to make searching easier.
![Get-PSNote Demo](Documentation/media/ADUserTag.gif)

### Quickly add your own notes
Add new snippets at any time
![New-PSNote Demo](Documentation/media/newnote.gif)

Add new snippets as string or by using a script block
![New-PSNote ScriptBlock Demo](Documentation/media/ScriptBlock.gif)

### Share your notes with others
The import and export functionality allows you to share notes between machines and people.
![Export/Import Demo](Documentation/media/ImportExport.gif)

# Getting Started
## Install Instructions
PowerShell v5+ and PowerShell v7+
```powershell
Install-Module PSNotes
```

[top](#psnotes)
# Commands

| Cmdlet | Synopsis |
| ------ | -------- |
| [ConvertTo-Splatting](Documentation/ConvertTo-Splatting.md) | Use to convert an existing PowerShell command to splatting |
| [Export-PSNote](Documentation/Export-PSNote.md) | Export PSNotes to a JSON file |
| [Get-CommandSplatting](Documentation/Get-CommandSplatting.md) | Use to output the parameters for a command in splatting format |
| [Get-PSNote](Documentation/Get-PSNote.md) | Search for or list PSNotes |
| [Get-PSNoteAlias](Documentation/Get-PSNoteAlias.md) | Use display snippet and copy to clipboard using an Alias |
| [Get-PSNoteMenu](Documentation/Get-PSNoteMenu.md) | Displays an interactive, paged menu of PSNotes and lets the user pick one by number. |
| [Get-RemoteCatalog](Documentation/Get-RemoteCatalog.md) | Gets configured remote catalogs. |
| [Import-PSNote](Documentation/Import-PSNote.md) | Import a PSNotes JSON file |
| [Import-PSNoteCatalog](Documentation/Import-PSNoteCatalog.md) | Use to import a PSNotes JSON fiile |
| [Import-RemoteCatalog](Documentation/Import-RemoteCatalog.md) | Registers or imports a remote catalog. |
| [Initialize-PSNoteStore](Documentation/Initialize-PSNoteStore.md) | Initialize the PSNotes store |
| [Initialize-PSNoteStoreRemoteJsonFile](Documentation/Initialize-PSNoteStoreRemoteJsonFile.md) | {{ Fill in the Synopsis }} |
| [Invoke-PSNote](Documentation/Invoke-PSNote.md) | Use to display a list of notes in a selectable menu so you can choose which to run |
| [Move-PSNote](Documentation/Move-PSNote.md) | Moves a note to a different catalog. |
| [New-PSNote](Documentation/New-PSNote.md) | Creates a new PSNote for storing and reusing code snippets or script references. |
| [Remove-PSNote](Documentation/Remove-PSNote.md) | Remove one or more PSNotes from the note store. |
| [Remove-RemoteCatalog](Documentation/Remove-RemoteCatalog.md) | Removes a remote catalog registration. |
| [Set-PSNote](Documentation/Set-PSNote.md) | Updates an existing PSNote or creates a new one if it doesn't exist. |
| [Test-PSNotesInitalize](Documentation/Test-PSNotesInitalize.md) | {{ Fill in the Synopsis }} |
| [Update-PSNoteStore](Documentation/Update-PSNoteStore.md) | Update PSNotes catalogs to the latest format |
| [Write-NoteSnippet](Documentation/Write-NoteSnippet.md) | {{ Fill in the Synopsis }} |

[top](#psnotes)
## Output and Run Notes
When you create a note in the PSNotes module you assign an alias to it. You can use this alias at any time to output, copy, or run a note. Simply type the name of the alias and hit enter to output it to your PowerShell console. You can also add the `-copy` switch to have the note copied to your clipboard or use the `-run` to execute the note directly.

###### Example 1: Output the note to the console
This example gets the note/code snippet with the alias "MyNote" and outputs it to the console.
```powershell
MyNote
```

###### Example 2: Output the note to the console
This example gets the note/code snippet with the alias "MyNote" and outputs it to the console and copies it to your local clipboard.
```powershell
MyNote -copy
```

###### Example 3: Execute the note directly
This example gets the note/code snippet with the alias "MyNote" and executes the command in your local session.
```powershell
MyNote -run
```
[top](#psnotes)
## Search Notes
Don't worry if you can't remember the alias you assigned to a note. You can use `Get-PSNote` to search your notes by name, tags, and keywords.

###### Example 1: Get all notes
This example gets all the notes currently loaded in your profile.
```powershell
Get-PSNote
```

###### Example 2: Get notes with a name that begins with string
This example gets all the notes that start with cred.
```powershell
Get-PSNote -Name 'cred*'
```

###### Example 3: Get notes with a name that contains a string
This example gets all the notes that have a name with the word "user" in it.
```powershell
Get-PSNote -Name '*user*'
```

###### Example 4: Get notes by tag
This example gets all the notes that have the tag "AD" assigned to them.
```powershell
Get-PSNote -Tag 'AD'
```

###### Example 4: Get notes that includes a search string
This example gets all the notes with the word "day" in the name, details, snippet text, alias, or tags.
```powershell
Get-PSNote -SearchString 'day'
```
[top](#psnotes)
## Creating Notes
You can create your own notes at any time using `New-PSNote`. Keep in mind that the snippet must be passed as string, so it is recommended to wrap them in single quotes and here-strings to prevent them from being executed when you are creating a note.

###### Example 1: Create a new note
This example creates a new note for the Get-ADUser cmdlet. Since the `-Alias` parameter is not supplied the Note value will be assigned as the alias.
```powershell
New-PSNote -Note 'ADUser' -Snippet 'Get-ADUser -Filter *' -Details "Use to return all AD users" -Tags 'AD','Users' 
```

###### Example 2: Create a new note with a custom alias
This example creates a new note with a custom alias.
```powershell
$Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
New-PSNote -Note 'DayOfWeek' -Snippet $Snippet -Details "Use to name of the day of the week" -Tags 'date' -Alias 'today'
```

###### Example 3: Create a new note using script block
This example creates a new note for the Get-WmiObject using a script block instead of a string. This make multiple line scripts easier to enter and gives you the ability to use auto-complete when entering it. 
```powershell
New-PSNote -Note 'CpuUsage' -Tags 'perf' -Alias 'cpu' -ScriptBlock {
    Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average
}
```

###### Example 4: Create a new note with both single and double quotes in it
This example shows one way you can create a new note for a snippet that contains both single and double quotes. Notice in the snippet itself the single quotes are doubled. This escapes them and tells PowerShell it is not the end of the string. 
```powershell
New-PSNote -Note 'SvcAccounts' -Snippet 'Get-ADUser -Filter ''Name -like "*SvcAccount"''' -Details "Use to return all AD Service Accounts" -Tags 'AD','Users' 
```

###### Example 5: Create multiple line note
When creating a note for a multiple line snippet, it is recommended that you use a here-string with single quotes to prevent expressions from being evaluated when you run the `New-PSNote` command.
```powershell
$Snippet = @'
$stringBuilder = New-Object System.Text.StringBuilder
for ($i = 0; $i -lt 10; $i++){
    $stringBuilder.Append("Line $i`r`n") | Out-Null
}
$stringBuilder.ToString()
'@
New-PSNote -Note 'StringBuilder' -Snippet $Snippet -Details "Use StringBuilder to combine multiple strings" -Tags 'string'
```
[top](#psnotes)
## Updating Notes
You can update a note at any time using `Set-PSNote`. With `Set-PSNote` you can update the Snippet, Details, Tags, or Alias of any note. In addition, notes can be deleted using `Remove-PSNote`.

###### Example 1: Set new tags
This example shows how to add the tags "AD" and "User" to the note ADUser
```powershell
Set-PSNote -Note 'ADUser' -Tags 'AD','Users'
```

###### Example 2: Update Snippet
This example shows how to update the snippet for the note DayOfWeek
```powershell
$Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
Set-PSNote -Note 'DayOfWeek' -Snippet $Snippet
```

###### Example 3: Delete a note 
This example shows how to delete a note named creds. This command does not accept wildcards, so the name of the note must match exactly.
```powershell
Remove-PSNote -Note 'creds'
```
[top](#psnotes)
## Sharing Notes
Not only does PSNotes allow you to create your own custom notes. It allows you to share them between computers and users. You can create a list of notes export them and share them with your team. Notes are stored in easy to read and edit JSON files in case you want to make manual edits.

Note: PSNotes stores your notes in your local AppData folder using the path %appdata%\PSNotes. By default, it places them in the file PSNotes.json. When you run the `Import-PSNote` cmdlet you can choose a catalog name. Doing so will cause the imported notes to be stored in a file with that catalogs name. 

###### Example 1: Export all notes
This example exports all notes to a JSON file.
```powershell
Export-PSNote -All -Path C:\Export\MyPSNotes.json
```

###### Example 2: Export a selection of notes
This example exports the notes with the tag AD to a JSON file.
```powershell
Get-PSNote -tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json
```

###### Example 3: Import to personal store
This example imports the contents of the file MyPSNotes.json and saves it to your personal PSNotes.json file.
```powershell
Import-PSNote -Path C:\Import\MyPSNotes.json
```

###### Example 4: Import to custom catalog file
This example imports the contents of the file SharedADNotes.json and saves it to the file ADNotes.json in the folder %APPDATA%\PSNotes
```powershell
Import-PSNote -Path C:\Export\SharedADNotes.json -Catalog 'ADNotes'
```
[top](#psnotes)
