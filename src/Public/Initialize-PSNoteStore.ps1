<#
.SYNOPSIS
Initializes the PSNotes store and required supporting files.

.DESCRIPTION
Initialize-PSNoteStore ensures the PSNotes store is present and ready for use. It creates the
required folder structure and base configuration files when they do not already exist.

This cmdlet is typically invoked automatically by other PSNotes commands as needed, but it can
also be called directly when setting up PSNotes on a new machine or when repairing an incomplete
store.

.FUNCTIONALITY
PSNotes Store Maintenance

.ROLE
Maintenance

.COMPONENT
Store

.PARAMETER Path
Specifies the root path where the PSNotes store should be created or validated.

If not specified, the default PSNotes store path is used.

.PARAMETER Force
Recreates missing files and folders and can overwrite base configuration artifacts where supported.

.PARAMETER PassThru
Returns the initialized store configuration object.

.EXAMPLE
PS> Initialize-PSNoteStore

Initializes the PSNotes store using the default location.

.OUTPUTS
System.Object

.NOTES
- This cmdlet prepares the store layout and configuration required by the PSNotes module.
- Most PSNotes commands will initialize the store automatically when needed.
- See also: Update-PSNoteStore, Get-PSNote
#>
Function Initialize-PSNoteStore {
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