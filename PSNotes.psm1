# Import the functions
foreach($folder in @('private', 'public')){
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if(Test-Path -Path $root)
    {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        # dot source each file
        $files | where-Object{ $_.name -NotLike '*.Tests.ps1'} |
            ForEach-Object{Write-Verbose $_.name; . $_.FullName}
    }
}

# Create Alias for Set-PSnote
Set-Alias -Name Set-PSNote -Value New-PSNote


# load the Json Files into an Object
[System.Collections.Generic.List[PSNote]] $script:noteObjects = @()
Function LoadPSNotesJsonFile{
    param($PSNotesJsonFile)
    
    if(-not (Test-Path $PSNotesJsonFile)){
        Write-Verbose "File not found : $PSNotesJsonFile"
        break
    } 
    
    $(Get-Content $PSNotesJsonFile -Raw | ConvertFrom-Json) | Select-Object Note, Snippet, Details, Alias, Tags, @{l='file';e={$PSNotesJsonFile}}| 
        ForEach-Object{ 
            $newNote = [PSNote]::New($_)
            $remove = $script:noteObjects | Where-Object{$_.Alias -eq $newNote.Alias}
            if($remove){
                $script:noteObjects.Remove($remove)
            }
            $script:noteObjects.Add($newNote) 
    }
}


# Import PSNotes Json File
LoadPSNotesJsonFile (Join-Path $PSScriptRoot 'PSNotes.json')


# Load the user file last to overwrite any duplicated with local config
$global:UserPSNotesJsonFile = Join-Path $env:APPDATA '\PSNotes\PSNotes.json'
LoadPSNotesJsonFile $UserPSNotesJsonFile


# load Aliases for commands
$noteObjects | ForEach-Object{
    Set-Alias -Name $_.Alias -Value Get-PSNoteAlias
}

# Check id Set-Clipboard cmdlet is found. If not
if(-not (Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)){
    # ClipboardText module is found then set an alias for the Set-Clipboard command
    if(Get-Module ClipboardText -ListAvailable){
        if(-not (Get-Alias -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)){
            Set-Alias -Name 'Set-Clipboard' -Value 'Set-ClipboardText'
        }
    } else {
        $warning = "Cmdlet 'Set-Clipboard' not found. Copy functionality will not work until this is resovled. " +
            "`n`t You can install the ClipboardText module from PowerShell Gallery, to add this functionality. " + 
            "`n`n`t`t Install-Module -Name ClipboardText`n" +
            "`n`t More Details: https://www.powershellgallery.com/packages/ClipboardText"
        Write-Warning $warning
    }
}