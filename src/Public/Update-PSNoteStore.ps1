function Update-PSNoteStore {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [ValidateSet('Prompt', 'SkipMigratedNotes', 'OverwriteExistingNotes')]
        [parameter(Mandatory = $false)]
        [string]$DefaultBehavior = 'Prompt'
    )
    
    Write-Verbose "Updating PSNoteStore to latest format..."

    $toMigrate = Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | ForEach-Object {
        if (-not [NoteCatalog]::VersionCheck($_.FullName)) {
            Write-Verbose "Migrating $($_.BaseName)..."
            $_
        }
    }

    foreach ($catalogPath in $toMigrate) {
        $migratedStore = [NoteCatalog]::Migrate($catalogPath.FullName, $true)
        Import-PSNoteCatalog -ImportedCatalog $migratedStore -DestinationCatalog $migratedStore.Catalog -DefaultBehavior $DefaultBehavior
    }

    Write-Verbose "PSNoteStore update complete."
}