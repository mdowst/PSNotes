Function Initialize-PSNotesJsonFile{
    # load the Json Files into an Object
    Function LoadPSNotesJsonFile{
        param($PSNotesJsonFile)
        Write-Verbose "Importing file : $PSNotesJsonFile"
        if(-not (Test-Path $PSNotesJsonFile)){
            Write-Warning "File not found : $PSNotesJsonFile"
            break
        } 
        
        $(Get-Content $PSNotesJsonFile -Raw | ConvertFrom-Json) | Select-Object Note, Snippet, Details, Alias, Tags, @{l='file';e={$PSNotesJsonFile}}| 
            ForEach-Object{ 
                $newNote = [PSNote]::New($_)
                $remove = $script:noteObjects | Where-Object{$_.Alias -eq $newNote.Alias}
                if($remove){
                    $script:noteObjects.Remove($remove) | Out-Null
                }
                $script:noteObjects.Add($newNote) 
        }
    }

    # Create PSNote folder in %APPDATA% to save user's local PSNote.json
    if(-not (Test-Path $UserPSNotesJsonPath)){
        New-Item -Type Directory -Path $UserPSNotesJsonPath | Out-Null
    }

    # Create PSNote.json in %APPDATA%\PSNotes to save users local settings
    if(-not (Test-Path $UserPSNotesJsonFile)){
        $exampleJson = '[{"Note":"NewPSNote","Alias":"Example","Details":"Example of creating a new Note","Tags":["notes"],' +
                    '"Snippet":"$Snippet = @\u0027\r\n(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)' +
                    '\r\n\u0027@\r\nNew-PSNote -Note \u0027DayOfWeek\u0027 -Snippet $Snippet -Details \"Use to name of the day of the week\"' +
                    ' -Tags \u0027date\u0027 -Alias \u0027today\u0027"}]'
        $exampleJson | Out-File $UserPSNotesJsonFile -Encoding UTF8
    }

    # load additional JSON store files
    Get-ChildItem -LiteralPath $UserPSNotesJsonPath -Filter "*.json" | Where-Object {$_.FullName -ne $UserPSNotesJsonFile} | 
        ForEach-Object{ LoadPSNotesJsonFile $_.FullName }

    # load the PSNote.json into $noteObjects
    LoadPSNotesJsonFile $UserPSNotesJsonFile

    # load Aliases for commands
    $noteObjects | ForEach-Object {
        Write-Debug "Alias : $($_.Alias)"
        Set-Alias -Name $_.Alias -Value Get-PSNoteAlias -Scope Global -Force
    }
}