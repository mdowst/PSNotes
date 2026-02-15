enum PSNoteKind {
    Snippet
    Script
}

enum PSNoteMenuItems{
    Main
    Catalogs
    Tags
    Favorites
    NoteList
    NoteActions
    Settings
    Help
    Exit
    Welcome
    AllCatalogs
    Preview
}

# Create the PSNote class
class PSNote {
    [string]$Note
    [string]$Snippet
    [string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$Catalog
    [bool]$Run = $false
    [PSNoteKind]$Kind = [PSNoteKind]::Snippet

    PSNote(
        [string]$Note,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags
    ) {
        $this.Note = $Note
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = 'Default'

        $this.Kind = [PSNoteKind]::Snippet
    }

    PSNote(
        [string]$Note,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags,
        [string]$Catalog,
        [bool]$Run
    ) {
        $this.Note = $Note
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = $Catalog
        $this.Run = $Run

        $this.Kind = [PSNoteKind]::Snippet
    }

    PSNote(
        [string]$Note,
        [PSNoteKind]$Kind,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags,
        [string]$Catalog,
        [bool]$Run
    ) {
        $this.Note = $Note
        $this.Kind = $Kind
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = $Catalog
        $this.Run = $Run

    }

    PSNote([object]$object) {
        $this.Note = $this.GetObjectProperty($object, 'Note')
        $this.Details = $this.GetObjectProperty($object, 'Details')
        $this.Alias = $this.GetObjectProperty($object, 'Alias')
        $this.Tags = $this.GetObjectProperty($object, 'Tags')
        $this.Catalog = $this.GetObjectProperty($object, 'Catalog')
        $this.Snippet = $this.GetObjectProperty($object, 'Snippet')

        # Run (existing behavior)
        $objRun = $this.GetObjectProperty($object, 'Run')
        $tryRun = $false
        if ([bool]::TryParse($objRun, [ref]$tryRun)) { $this.Run = $tryRun } else { $this.Run = $false }

        # --- Kind (new, but tolerate missing/invalid) ---
        $kindText = $null
        if ($null -ne $object.PSObject.Properties['Kind']) {
            $kindText = [string]$object.Kind
        }

        if ([string]::IsNullOrWhiteSpace($kindText)) {
            $this.Kind = [PSNoteKind]::Snippet
        }
        else {
            try { $this.Kind = [PSNoteKind]::$kindText }
            catch { $this.Kind = [PSNoteKind]::Snippet }
        }
    }

    [object] GetObjectProperty([object]$object, [string]$propertyName) {
        if ($null -ne $object.PSObject.Properties[$propertyName]) {
            return $object.$propertyName
        }
        return $null
    }

    [string] GetKey() {
        return "$($this.Catalog)::$($this.Alias)"
    }

    # Optional helper: what do we show in menus?
    [string] GetDisplayText() {
        $out = switch ($this.Kind) {
            Script { "$($this.Alias) (Script)" }
            default { "$($this.Alias)" }
        }
        return $out
    }
}

class NoteCatalog {
    static [int] $CurrentStoreVersion = 1

    [string] $Path
    [string] $Catalog
    [int]    $StoreVersion
    [System.Collections.Generic.List[PSNote]] $Notes

    NoteCatalog() {
        [NoteStore]::InitializeEnvironment()
        $this.Path = [NoteCatalog]::ResolvePath('Default', $env:PSNOTES_HOME)
        $this.Catalog = 'Default'
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([string] $Catalog) {
        [NoteStore]::InitializeEnvironment()
        $this.Path = [NoteCatalog]::ResolvePath($Catalog, $env:PSNOTES_HOME)
        $this.Catalog = $Catalog
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([bool] $blank) {
        $this.Path = [NoteCatalog]::ResolvePath('Default', $env:PSNOTES_HOME)
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
    }

    static [string] ResolvePath() {
        return [NoteCatalog]::ResolvePath('Default', $env:PSNOTES_HOME)
    }

    static [string] ResolvePath([string] $catalog) {
        return [NoteCatalog]::ResolvePath($catalog, $env:PSNOTES_HOME)
    }

    static [string] ResolvePath([string] $catalog = 'Default', [string] $rootPath = $env:PSNOTES_HOME) {
        if ([string]::IsNullOrWhiteSpace($rootPath)) {
            $rootPath = Join-Path $env:APPDATA 'PSNotes'
        }
        if (-not (Test-Path $rootPath)) {
            $null = New-Item -Path $rootPath -ItemType Directory -Force
        }

        $fileName = if ($catalog -match '\.json$') { $catalog } else { "$catalog.json" }
        return (Join-Path $rootPath $fileName)
    }

    [void] Open() {
        $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)

        if (-not [string]::IsNullOrWhiteSpace($Json)) {
            $data = $Json | ConvertFrom-Json -ErrorAction Stop
            $dataStoreVersion = $data.psobject.Properties | Where-Object { $_.Name -eq 'StoreVersion' } | Select-Object -ExpandProperty Value

            # Migration / backward-compat:
            # If older store was just an array of notes, wrap it.
            if ($dataStoreVersion -ne $this.StoreVersion) {
                Write-Warning "Note catalog store version mismatch in $($this.Catalog). Expected: $($this.StoreVersion), Found: $($dataStoreVersion)`n         Notes from $($this.Catalog) will not be loaded.`n`n    Run 'Update-PSNoteStore' to migrate legacy store catalogs.`n"
                return
            }

            $data.Notes | ForEach-Object {
                $note = [PSNote]::New($_)
                if ([string]::IsNullOrWhiteSpace($note.Catalog)) {
                    $note.Catalog = $this.Catalog
                }
                $this.Notes.Add($note)
            }
        }

        if ($null -eq $this.Catalog) {
            $this.Catalog = [System.IO.Path]::GetFileNameWithoutExtension($this.Path)
        }
        # Future: if ($store.StoreVersion -lt CurrentStoreVersion) { $store.Migrate() }
    }

    static [NoteCatalog] Open([string] $catalogPath) {
        $store = [NoteCatalog]::new($true)
        $store.Path = $catalogPath
        $store.Open()
        
        return $store
    }

    static [bool] VersionCheck([string] $catalogPath) {
        $currentVersion = $false
        $json = [NoteCatalog]::ReadUtf8NoBom($catalogPath)

        if (-not [string]::IsNullOrWhiteSpace($Json)) {
            $data = $Json | ConvertFrom-Json -ErrorAction Stop
            $dataStoreVersion = $data.psobject.Properties | Where-Object { $_.Name -eq 'StoreVersion' } | Select-Object -ExpandProperty Value

            # If store version matches current, return true
            if ($dataStoreVersion -eq [NoteCatalog]::CurrentStoreVersion) {
                $currentVersion = $true
            }
        }
        return $currentVersion
    }

    static [hashtable] ValidateNotes([string] $catalogPath) {
        $result = @{
            IsValid      = $true
            StoreVersion = $null
            Errors       = [System.Collections.Generic.List[string]]::new()
            Warnings     = [System.Collections.Generic.List[string]]::new()
        }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($catalogPath)
            
            if ([string]::IsNullOrWhiteSpace($json)) {
                $result.IsValid = $false
                $result.Errors.Add("File is empty or does not exist")
                return $result
            }

            $data = $json | ConvertFrom-Json -ErrorAction Stop

            # Check the store version
            $dataStoreVersion = $data.psobject.Properties | Where-Object { $_.Name -eq 'StoreVersion' } | Select-Object -ExpandProperty Value
            if ($dataStoreVersion -eq [NoteCatalog]::CurrentStoreVersion) {
                $result.StoreVersion = 'Current'
            }
            elseif (-not [string]::IsNullOrWhiteSpace($dataStoreVersion)) {
                $result.StoreVersion = $dataStoreVersion
                $result.Warnings.Add("Note catalog store version mismatch. Expected: $([NoteCatalog]::CurrentStoreVersion), Found: $dataStoreVersion")
            }
            else {
                $result.StoreVersion = 'Legacy'
            }
            # Determine if this is old format (array) or new format (object with Notes property)
            $legacyNotes = $data.psobject.Properties | Where-Object { $_.Name -eq 'Note' } | Select-Object -ExpandProperty Value
            $currentNotes = $data.psobject.Properties | Where-Object { $_.Name -eq 'Notes' } | Select-Object -ExpandProperty Value
            $vnotes = if ($data -is [array] -or $null -ne $legacyNotes) {
                $data
                $result.Warnings.Add("Legacy note catalog format detected (array). Consider migrating to new format.")
            }
            elseif ($null -ne $currentNotes) {
                $data.Notes
            }
            else {
                $result.IsValid = $false
                $result.Errors.Add("Invalid JSON structure: expected array or object with 'Notes' property")
                return $result
            }

            if ($null -eq $vnotes -or @($vnotes).Count -eq 0) {
                $result.IsValid = $false
                $result.Errors.Add("No notes found in catalog")
                return $result
            }

            $index = 0
            foreach ($note in $vnotes) {
                $noteErrors = [System.Collections.Generic.List[string]]::new()
                
                # Check for Note property
                $noteValue = $null
                if ($null -ne $note.PSObject.Properties['Note']) {
                    $noteValue = [string]$note.Note
                }
                if ([string]::IsNullOrWhiteSpace($noteValue)) {
                    $noteErrors.Add("Note[$index]: Missing or empty 'Note' property")
                }

                # Check for Snippet property
                $snippetValue = $null
                if ($null -ne $note.PSObject.Properties['Snippet']) {
                    $snippetValue = [string]$note.Snippet
                }
                if ([string]::IsNullOrWhiteSpace($snippetValue)) {
                    $noteErrors.Add("Note[$index]: Missing or empty 'Snippet' property")
                }

                # Additional validation: warn if Alias is missing (will default to Note)
                if ($null -eq $note.PSObject.Properties['Alias'] -or [string]::IsNullOrWhiteSpace([string]$note.Alias)) {
                    if (-not [string]::IsNullOrWhiteSpace($noteValue)) {
                        $result.Warnings.Add("Note[$index] '$noteValue': Missing 'Alias' property (will default to Note name)")
                    }
                }

                if ($noteErrors.Count -gt 0) {
                    $result.IsValid = $false
                    foreach ($err in $noteErrors) {
                        $result.Errors.Add($err)
                    }
                }

                $index++
            }
        }
        catch {
            $result.IsValid = $false
            $result.Errors.Add("Failed to parse JSON: $($_.Exception.Message)")
        }

        return $result
    }

    static [NoteCatalog] Migrate([string] $catalogPath, [bool] $backup = $true) {
        $migrate = [NoteCatalog]::new($true)
        $migrate.Path = $catalogPath
        $migrate.Catalog = [System.IO.Path]::GetFileNameWithoutExtension($catalogPath)

        # Read the old format JSON
        $json = [NoteCatalog]::ReadUtf8NoBom($catalogPath)
        if ([string]::IsNullOrWhiteSpace($json)) {
            return $migrate
        }
        
        try {
            $oldData = $json | ConvertFrom-Json -ErrorAction Stop
            $fileName = [System.IO.Path]::GetFileName($catalogPath)
            $backupDir = Join-Path $env:PSNOTES_HOME 'backups'
            $backupStamp = (Get-Date).ToString('yyyyMMdd_HHmmssfff')
            $backupPath = Join-Path $backupDir "$fileName.pre-migration.$backupStamp.bak"
            $tempPath = Join-Path $backupDir "$fileName.$backupStamp.tmp"
            $migrate.Path = $tempPath
            # Backup the original file before migration
            if (-not (Test-Path $backupDir)) {
                $null = New-Item -Path $backupDir -ItemType Directory -Force
            }
            [System.IO.File]::Copy($catalogPath, $backupPath, $true)
            [System.IO.File]::Copy($catalogPath, $tempPath, $true)

            # Convert old format (array) to new format (object with StoreVersion, Catalog, Notes)
            # Old format: [{ Note, Snippet, Details, Alias, Tags }, ...]
            # New format: { StoreVersion, Catalog, Notes: [...] }
            $oldData | ForEach-Object {
                $note = [PSNote]::New($_)
                if ([string]::IsNullOrWhiteSpace($note.Catalog)) {
                    $note.Catalog = $migrate.Catalog
                }
                $migrate.Notes.Add($note)
            }
            
            if ($backup) {
                # Save in new format using atomic backup
                [NoteCatalog]::AtomicSaveWithBackup($tempPath, $json, 'migrationv1-')
                
                # Confirm that $catalogPath and $backupPath are the same and if so delete $catalogPath
                if ((Get-FileHash -Path $catalogPath).Hash -eq (Get-FileHash -Path $backupPath).Hash) {
                    [System.IO.File]::Delete($catalogPath)
                }
                
                Write-Verbose "Successfully migrated $fileName to new format. Backup saved to $backupPath"
            }
            $migrate.Save()
        }
        catch {
            throw "Failed to migrate catalog at $catalogPath : $_"
        }
        
        return $migrate
    }

    [void] RemoveNote([string] $note, [bool] $save = $true) {
        $remove = $this.Notes | Where-Object { $_.Note -eq $note }
        if ($remove) {
            $this.Notes.Remove($remove) | Out-Null
            if ($save) {
                $this.Save()
            }
        }
        else {
            Write-Warning "Note '$note' not found in catalog. No action taken."
        }
    }

    [string] ToJson() {
        $obj = [pscustomobject]@{
            StoreVersion = $this.StoreVersion
            Catalog      = $this.Catalog
            Notes        = @($this.Notes | Select-Object -Property * -ExcludeProperty Catalog)
        }
        return ($obj | ConvertTo-Json -Depth 10)
    }

    [void] Save() {
        # Always write current version
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion

        $json = $this.ToJson()
        [NoteCatalog]::AtomicSaveWithBackup($this.Path, $json)
    }

    static [System.IO.FileStream] AcquireLock([string] $path, [int] $timeoutMs = 5000, [int] $retryDelayMs = 50) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $last = $null

        while ($sw.ElapsedMilliseconds -lt $timeoutMs) {
            try {
                # Lock the store file itself; write-through this stream in Save()
                return [System.IO.File]::Open(
                    $path,
                    [System.IO.FileMode]::OpenOrCreate,
                    [System.IO.FileAccess]::ReadWrite,
                    [System.IO.FileShare]::None
                )
            }
            catch {
                $last = $_
                Start-Sleep -Milliseconds $retryDelayMs
            }
        }

        throw "Timed out acquiring lock for note store file: $path. Last error: $($last.Exception.Message)"
    }

    static [string] ReadUtf8NoBom([string] $path) {
        if (-not (Test-Path $path)) { return $null }

        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            $sr = [System.IO.StreamReader]::new($fs, $utf8NoBom, $true)
            try { return $sr.ReadToEnd() } finally { $sr.Dispose() }
        }
        finally { $fs.Dispose() }
    }

    static [void] AtomicSaveWithBackup([string] $path, [string] $content) {
        [NoteCatalog]::AtomicSaveWithBackup($path, $content, '')
    }

    static [void] AtomicSaveWithBackup([string] $path, [string] $content, [string] $prefix) {
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        $directory = $ENV:PSNOTES_HOME
        $fileName = [System.IO.Path]::GetFileName($path)
        $tempPath = Join-Path $directory "$fileName.tmp"
        $backupDir = Join-Path $directory 'backups'
        $backupStamp = (Get-Date).ToString('yyyyMMdd_HHmmssfff')
        $backupPath = Join-Path $backupDir "$prefix$fileName.$backupStamp.bak"

        # Ensure directory exists
        if (-not (Test-Path $directory)) {
            $null = New-Item -Path $directory -ItemType Directory -Force
        }
        # Ensure backup directory exists
        if (-not (Test-Path $backupDir)) {
            $null = New-Item -Path $backupDir -ItemType Directory -Force
        }

        try {
            # Step 1: Write to temp file
            [System.IO.File]::WriteAllText($tempPath, $content, $utf8NoBom)

            # Step 2: Acquire lock on the target file (or create if doesn't exist)
            $lockStream = [NoteCatalog]::AcquireLock($path, 5000, 50)
            try {
                $lockStream.Close()
                $lockStream.Dispose()

                # Step 3: Create backup if original exists
                if (Test-Path $path) {
                    # Copy current file to timestamped backup
                    [System.IO.File]::Copy($path, $backupPath, $true)

                    # Keep only the last 10 backups for this file
                    $backupPattern = "$fileName.*.bak"
                    $oldBackups = Get-ChildItem -Path $backupDir -Filter $backupPattern -File |
                    Sort-Object -Property LastWriteTime -Descending |
                    Select-Object -Skip 10
                    foreach ($old in $oldBackups) {
                        try { [System.IO.File]::Delete($old.FullName) } 
                        catch { Write-Error "Failed to delete old backup file: $($_.Exception.Message)" }
                    }
                }

                # Step 4: Replace original with temp (atomic operation on NTFS/most filesystems)
                [System.IO.File]::Copy($tempPath, $path, $true)

                # Step 5: Clean up temp file
                if (Test-Path $tempPath) {
                    [System.IO.File]::Delete($tempPath)
                }
            }
            catch {
                # If anything goes wrong, ensure lock is released
                if ($null -ne $lockStream) {
                    try { $lockStream.Dispose() } 
                    catch { Write-Error "Failed to dispose lock stream: $_" }
                }
                throw
            }
        }
        catch {
            # Clean up temp file if it exists
            if (Test-Path $tempPath) {
                try { [System.IO.File]::Delete($tempPath) } 
                catch { Write-Error "Failed to delete temp file: $_" }
            }
            throw "Failed to save note store atomically: $_"
        }
    }
}

class NoteMetadataStore {
    static [int] $CurrentVersion = 1

    [string] $Path
    [int] $Version
    [System.Collections.Generic.HashSet[string]] $Favorites

    NoteMetadataStore() {
        $metaPath = Join-Path $env:PSNOTES_HOME 'config'
        if (-not (Test-Path $metaPath)) {
            $null = New-Item -Path $metaPath -ItemType Directory -Force
        }
        $this.Path = (Join-Path $metaPath 'psnotemetadatastore.json')
        $this.Version = [NoteMetadataStore]::CurrentVersion
        $this.Favorites = [System.Collections.Generic.HashSet[string]]::new()
        $this.Open()
    }

    NoteMetadataStore([string] $path) {
        $this.Path = $path
        $this.Version = [NoteMetadataStore]::CurrentVersion
        $this.Favorites = [System.Collections.Generic.HashSet[string]]::new()
        $this.Open()
    }

    [void] Open() {
        if (-not (Test-Path $this.Path)) { return }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)
            if ([string]::IsNullOrWhiteSpace($json)) { return }

            $data = $json | ConvertFrom-Json -ErrorAction Stop
            if ($data.Favorites) {
                foreach ($k in $data.Favorites) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$k)) {
                        $null = $this.Favorites.Add([string]$k)
                    }
                }
            }
        }
        catch {
            # If metadata is corrupt, fail safe (don't crash UI). You can add logging later.
            return
        }
    }

    [string] ToJson() {
        return ($this | ConvertTo-Json -Depth 5)
    }

    [void] Save() {
        $json = $this.ToJson()
        [NoteCatalog]::AtomicSaveWithBackup($this.Path, $json)
    }
}

class NoteConfigStore {
    static [int] $CurrentVersion = 1

    [string] $Path
    [int] $Version
    [PSNoteMenuItems] $Main
    [bool] $ExitOnCopy
    [ConsoleColor] $ForegroundColor
    [ConsoleColor] $BackgroundColor

    NoteConfigStore() {
        $metaPath = Join-Path $env:PSNOTES_HOME 'config'
        if (-not (Test-Path $metaPath)) {
            $null = New-Item -Path $metaPath -ItemType Directory -Force
        }
        $this.Path = (Join-Path $metaPath 'psnoteconfig.json')
        $this.SetDefaults()
        $this.Open()
    }

    NoteConfigStore([string] $path) {
        $this.Path = $path
        $this.SetDefaults()
        $this.Open()
    }

    [void] SetDefaults() {
        $this.Version = [NoteConfigStore]::CurrentVersion
        $this.Main = [PSNoteMenuItems]::Welcome
        $this.ExitOnCopy = $true
        $this.ForegroundColor = [ConsoleColor]::Black
        $this.BackgroundColor = [ConsoleColor]::Gray
    }

    [void] Open() {
        if (-not (Test-Path $this.Path)) { return }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)
            if ([string]::IsNullOrWhiteSpace($json)) { return }

            $data = $json | ConvertFrom-Json -ErrorAction Stop
            if (-not [string]::IsNullOrWhiteSpace([string]$data.Main)) {
                $tryFg = [PSNoteMenuItems]::Welcome
                if ([Enum]::TryParse([string]$data.Main, [ref]$tryFg)) {
                    $this.Main = $tryFg
                }
            }
            if ($null -ne $data.ExitOnCopy) {
                $tryExitOnCopy = $false
                if ([bool]::TryParse($data.ExitOnCopy, [ref]$tryExitOnCopy)) {
                    $this.ExitOnCopy = $tryExitOnCopy
                }
            }
            if ($null -ne $data.ForegroundColor) {
                $tryFg = [ConsoleColor]::Black
                if ([Enum]::TryParse([string]$data.ForegroundColor, [ref]$tryFg)) {
                    $this.ForegroundColor = $tryFg
                }
            }
            if ($null -ne $data.BackgroundColor) {
                $tryBg = [ConsoleColor]::Gray
                if ([Enum]::TryParse([string]$data.BackgroundColor, [ref]$tryBg)) {
                    $this.BackgroundColor = $tryBg
                }
            }
        }
        catch {
            # If metadata is corrupt, fail safe (don't crash UI). You can add logging later.
            return
        }
    }

    [string] ToJson() {
        return ($this | ConvertTo-Json -Depth 5)
    }

    [void] Save() {
        $json = $this.ToJson()
        [NoteCatalog]::AtomicSaveWithBackup($this.Path, $json)
    }
}

class NoteStore {
    static [int] $CurrentStoreVersion = 1

    [System.Collections.Generic.List[NoteCatalog]] $Catalogs
    [System.Collections.Generic.List[PSNote]] $Notes
    [NoteMetadataStore] $Metadata
    [NoteConfigStore] $Config

    NoteStore() {
        [NoteStore]::InitializeEnvironment()
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Catalogs = [System.Collections.Generic.List[NoteCatalog]]::new()

        $defaultStore = [NoteCatalog]::new()
        $this.LoadCatalog($defaultStore)

        $this.Metadata = [NoteMetadataStore]::new()
        $this.Config = [NoteConfigStore]::new()

        $this.InitializeAliases()
    }

    static [void] InitializeEnvironment() {
        if ([string]::IsNullOrEmpty($env:PSNOTES_HOME)) {
            if (Get-Variable -Name IsLinux -Scope Global -ValueOnly -ErrorAction SilentlyContinue) {
                $env:PSNOTES_HOME = '/home/PSNotes'
            } 
            else {
                $env:PSNOTES_HOME = Join-Path $env:APPDATA 'PSNotes'
            }
        }
    }

    [void] LoadCatalog([string] $catalogName) {
        $catalog = [NoteCatalog]::new($catalogName)
        $this.LoadCatalog($catalog)
    }

    [void] LoadCatalog([NoteCatalog] $catalog) {
        $catalog.Notes | ForEach-Object { 
            $newNote = $_
            $dup = if(-not [string]::IsNullOrWhiteSpace($newNote.Alias)){
                $this.Notes | Where-Object { $_.Alias -eq $newNote.Alias }
            }
            else {
                $this.Notes | Where-Object { $_.Note -eq $newNote.Note }
            }
            if ($dup -and $dup.Catalog -ne $newNote.Catalog) {
                Write-Warning "Duplicate Alias found: $($newNote.Alias). Skipping note: $($newNote.Note)"
            }
            elseif (-not $dup) {
                $this.Notes.Add($newNote) 
            }
        }
        if (-not ($this.Catalogs | Where-Object { $_.Catalog -eq $catalog.Catalog })) {
            $this.Catalogs.Add($catalog)
        }
    }

    [void] InitializeAliases() {
        $this.Notes | ForEach-Object {
            Write-Debug "Alias : $($_.Alias)"
            if ([string]::IsNullOrWhiteSpace($_.Alias)) { 
                Write-Verbose "Note '$( $_.Note )' has an empty Alias. Skipping alias creation." 
            }
            else{
                Set-Alias -Name $_.Alias -Value Get-PSNoteAlias -Scope Global -Force
            }
        }
    }

    [void] Save() {
        $this.Catalogs | ForEach-Object {
            $_.Save()
        }
    }

    [void] AddNote([PSNote] $note) {
        $this.Notes.Add($note) | Out-Null

        if (-not ($this.Catalogs | Where-Object { $_.Catalog -eq $note.Catalog })) {
            $newCatalog = [NoteCatalog]::new($note.Catalog)
            $this.Catalogs.Add($newCatalog)
        }

        $catalogUpdates = $this.Catalogs | Where-Object { $_.Catalog -eq $note.Catalog } | ForEach-Object {
            $_.Notes.Add($note) | Out-Null
            $_
        }
        $catalogUpdates | ForEach-Object {
            $_.Save()
            $this.LoadCatalog($_)
        }
    }

    [void] RemoveNote([string] $note, [string] $catalog) {
        $this.RemoveNote($note, $catalog, $true)
    }

    [void] RemoveNote([string] $note, [string] $catalog, [bool] $reload) {
        $remove = $this.Notes | Where-Object { $_.Note -eq $note -and $_.Catalog -eq $catalog }
        if ($remove) {
            $this.Notes.Remove($remove) | Out-Null
            $catalogUpdates = $this.Catalogs | Where-Object { $_.Catalog -eq $remove.Catalog } | ForEach-Object {
                $_.Notes.Remove($remove) | Out-Null
                $_
            }
            if ( $reload ) {
                # TODO: $this.Metadata.RemoveFavorite($remove)
                $catalogUpdates | ForEach-Object {
                    $_.Save()
                    $this.LoadCatalog($_)
                }
            }
        }
        else {
            Write-Warning "Note '$note' not found in catalog '$catalog'. No action taken."
        }
    }

    [void] UpdateNote([PSNote] $note) {
        $noteNote = if ($null -ne $note.PSObject.Properties['Note']) {
            [string]$note.Note
        }
        $noteCatalog = if ($null -ne $note.PSObject.Properties['Kind']) {
            [string]$note.Catalog
        }
        $update = $this.Notes | Where-Object { $_.Note -eq $noteNote }
        
        if (-not $update) {
            Write-Warning "Note '$($noteNote)' not found in catalog '$($noteCatalog)'. No action taken."
            return
        }
        elseif ($update.Catalog -eq $noteCatalog) {
            $this.RemoveNote($noteNote, $noteCatalog, $false)
            $this.AddNote($note)
        }
        else {
            Write-Warning "Note '$($noteNote)' exists in catalog '$($update.Catalog)'. Cannot update note in different catalog at this time '$($noteCatalog)'. No action taken."
        }
    }

    [string] GetNoteKey([PSNote] $note) {
        return "$($note.Catalog)::$($note.Note)::$($note.Alias)"
    }

    [bool] IsFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return $false }
        return $this.Metadata.Favorites.Contains($this.GetNoteKey($note))
    }

    [void] AddFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return }
        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Add($key)) { $this.Metadata.Save() }
    }

    [void] RemoveFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return }
        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Remove($key)) { $this.Metadata.Save() }
    }

    [bool] ToggleFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return $false }

        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Contains($key)) {
            $null = $this.Metadata.Favorites.Remove($key)
            $this.Metadata.Save()
            return $false
        }
        else {
            $null = $this.Metadata.Favorites.Add($key)
            $this.Metadata.Save()
            return $true
        }
    }

    [System.Collections.Generic.List[PSNote]] GetFavorites() {
        $list = [System.Collections.Generic.List[PSNote]]::new()
        if (-not $this.Metadata) { return $list }

        foreach ($n in $this.Notes) {
            if ($this.Metadata.Favorites.Contains($this.GetNoteKey($n))) {
                $list.Add($n) | Out-Null
            }
        }
        return $list
    }
}