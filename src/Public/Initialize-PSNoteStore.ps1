Function Initialize-PSNoteStore {
    <#
    .SYNOPSIS
        Initialize the PSNotes store

    .DESCRIPTION
        Loads all PSNotes catalogs from $env:PSNOTES_HOME into the in-memory note store
        and verifies clipboard support. This is typically called internally by other
        commands, but can be invoked to refresh the store after external changes.

    .EXAMPLE
        Initialize-PSNoteStore

        Initializes the PSNotes store by loading catalogs from $env:PSNOTES_HOME.

    .EXAMPLE
        $env:PSNOTES_HOME = 'C:\Users\Me\AppData\Roaming\PSNotes'
        Initialize-PSNoteStore

        Initializes the store using a custom PSNotes home path.

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [CmdletBinding()]
    param()

    # Load all commands to noteObjects
    #Initialize-PSNoteStoreRemoteJsonFile
    $script:_noteStore = [NoteStore]::new()
    Write-Verbose "User PSNotes Path: $env:PSNOTES_HOME"
    $script:_noteStore.InitializeAliases()

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