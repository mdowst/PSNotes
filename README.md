# PSNotes

PSNotes is a PowerShell module that allows you to create your own custom snippet library, that you can use to reference commands you run often. Or ones you don't run often and need a reminder on. Snippets can either be executed directly, copied to your clipboard, or simply output to the display for you to do whatever you want with them. When you create a note you assign an alias to it, so you can have an easy to remember keyword that you can then use to recall it. Notes can also be classified with tags, so you can easily search for them. 

# Install Instructions
PowerShell v5 and PowerShell Core
```powershell
Install-Module PSnotes
```
Note: As of the time of publishing Set-Clipboard is not supported in PowerShell Core. To use the copy to clipboard functionality of this module, it is recommended that you also install the ClipboardText module.

```powershell
Install-Module -Name ClipboardText
```

# Key Features
[here](#Share-your-notes-with-others)

### Recall a command using a specific alias keyword
When you create a new note you can define an alias that you can later use to display or run it.
![UnixTime Demo](Documentation/UnixTime.gif)

Perfect for long commands you need to run often.
![AzCon Demo](Documentation/AzCon.gif)

### Easily search your notes
You can assign tags to your notes to make searching easier.
![Get-PSNote Demo](Documentation/ADUserTag.gif)

### Quickly add your own notes
Add new snippets at any time
![New-PSNote Demo](Documentation/newnote.gif)

### Share your notes with others
The import and export functionality allows you to share notes between machines and people.
![Export/Import Demo](Documentation/ImportExport.gif)

```powershell
Import-PSNote -Path C:\Import\MyPSNotes.json
```
