Function Initialize-PSNoteStore {
    [CmdletBinding()]
    param()

    # Load all commands to noteObjects
    #Initialize-PSNoteStoreRemoteJsonFile
    $script:_noteStore = [NoteStore]::new()
    Write-Verbose "User PSNotes Path: $env:PSNOTES_HOME"
    Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | Where-Object{ $_.BaseName -notin 'Default' } | ForEach-Object {
        $script:_noteStore.LoadCatalog($_.BaseName)
    }

    # Check id Set-Clipboard cmdlet is found. If not
    if (-not (Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)) {
        # ClipboardText module is found then set an alias for the Set-Clipboard command
        if (Get-Module ClipboardText -ListAvailable) {
            if (-not (Get-Alias -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)) {
                Set-Alias -Name 'Set-Clipboard' -Value 'Set-ClipboardText'
            }
        }
        else {
            $warning = "Cmdlet 'Set-Clipboard' not found. Copy functionality will not work until this is resolved. " +
            "`n`t You can install the ClipboardText module from PowerShell Gallery, to add this functionality. " + 
            "`n`n`t`t Install-Module -Name ClipboardText`n" +
            "`n`t More Details: https://www.powershellgallery.com/packages/ClipboardText"
            Write-Warning $warning
        }
    }
}