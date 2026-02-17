enum PSNoteKind {
    Snippet
    Script
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
    [bool] $IsRemote = $false

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
        if (Test-Path $Catalog) {
            $this.Path = $Catalog
        }
        else {
            $this.Path = [NoteCatalog]::ResolvePath($Catalog, $env:PSNOTES_HOME)
        }
        $this.Catalog = [System.IO.Path]::GetFileNameWithoutExtension($this.Path)
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([bool] $blank) {
        $this.Path = [NoteCatalog]::ResolvePath('Default', $env:PSNOTES_HOME)
        $this.Catalog = [System.IO.Path]::GetFileNameWithoutExtension($this.Path)
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
            $catalogName = $data.psobject.Properties | Where-Object { $_.Name -eq 'Catalog' } | Select-Object -ExpandProperty Value
            if ([string]::IsNullOrWhiteSpace($catalogName)) {
                $catalogName = [System.IO.Path]::GetFileNameWithoutExtension($this.Path)
            }
            $this.Catalog = $catalogName
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

class RemoteCatalogSource {
    [string] $Name
    [string] $Url
    [string] $CacheFile   # relative to PSNOTES_HOME (recommended)
    [string] $LastSync    # ISO 8601 string
    [string] $ETag
    [string] $LastModified
    [bool]   $Enabled = $true

    RemoteCatalogSource() {}

    RemoteCatalogSource([string] $name, [string] $url, [string] $cacheFile) {
        $this.Name = $name
        $this.Url = $url
        $this.CacheFile = $cacheFile
        $this.Enabled = $true
    }
}

class NoteConfigStore {
    static [int] $CurrentVersion = 1

    [string] $Path
    [int]    $Version
    [System.Collections.Generic.List[RemoteCatalogSource]] $RemoteCatalogs

    NoteConfigStore() {
        $configPath = Join-Path $env:PSNOTES_HOME 'config'
        if (-not (Test-Path $configPath)) { $null = New-Item -Path $configPath -ItemType Directory -Force }

        $this.Path = (Join-Path $configPath 'psnoteconfigstore.json')
        $this.Version = [NoteConfigStore]::CurrentVersion
        $this.RemoteCatalogs = [System.Collections.Generic.List[RemoteCatalogSource]]::new()
        $this.Open()
    }

    [void] Open() {
        if (-not (Test-Path $this.Path)) { return }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)
            if ([string]::IsNullOrWhiteSpace($json)) { return }

            $data = $json | ConvertFrom-Json -ErrorAction Stop

            if ($data.RemoteCatalogs) {
                foreach ($rc in $data.RemoteCatalogs) {
                    $r = [RemoteCatalogSource]::new()
                    $r.Name = [string]$rc.Name
                    $r.Url = [string]$rc.Url
                    $r.CacheFile = [string]$rc.CacheFile
                    $r.LastSync = [string]$rc.LastSync
                    $r.ETag = [string]$rc.ETag
                    $r.LastModified = [string]$rc.LastModified

                    $enabled = $true
                    if ($null -ne $rc.PSObject.Properties['Enabled']) {
                        [void][bool]::TryParse([string]$rc.Enabled, [ref]$enabled)
                    }
                    $r.Enabled = $enabled

                    if (-not [string]::IsNullOrWhiteSpace($r.Url)) {
                        $this.RemoteCatalogs.Add($r) | Out-Null
                    }
                }
            }
        }
        catch {
            # fail safe
            return
        }
    }

    [void] Save() {
        $json = ($this | ConvertTo-Json -Depth 8)
        [NoteCatalog]::AtomicSaveWithBackup($this.Path, $json)
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
        $this.Metadata = [NoteMetadataStore]::new()
        $this.Config = [NoteConfigStore]::new()
        $this.LoadLocalCatalogs()
        $this.LoadRemoteCatalogs()
        $this.InitializeAliases()
    }

    [void] LoadLocalCatalogs() {
        $catalogFiles = Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' -File -ErrorAction SilentlyContinue
        if ($catalogFiles) {
            foreach ($file in $catalogFiles) {
                try {
                    $this.LoadCatalog($file.BaseName)
                }
                catch {
                    Write-Warning "Failed to load note catalog from file '$($file.FullName)': $($_.Exception.Message)"
                }
            }
        }
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

    hidden [NoteCatalog] GetCatalogObject([string] $catalogName) {
        return $this.Catalogs |
        Where-Object { $_.Catalog -eq $catalogName } |
        Select-Object -First 1
    }

    [void] LoadCatalog([string] $catalogName) {
        $catalog = [NoteCatalog]::new($catalogName)
        $this.LoadCatalog($catalog)
    }

    [void] LoadCatalog([NoteCatalog] $catalog) {
        $catalog.Notes | ForEach-Object { 
            $newNote = $_
            $dup = if (-not [string]::IsNullOrWhiteSpace($newNote.Alias)) {
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
            else {
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
        # Block adding notes into remote catalogs
        $cat = $this.GetCatalogObject($note.Catalog)
        if ($cat -and $cat.IsRemote) {
            Write-Warning "Cannot add notes to remote catalog '$($note.Catalog)'. Remote catalogs are read-only."
            return
        }

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
        # Block removing notes from remote catalogs
        $cat = $this.GetCatalogObject($catalog)
        if ($cat -and $cat.IsRemote) {
            Write-Warning "Cannot remove notes from remote catalog '$catalog'. Remote catalogs are read-only."
            return
        }

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

        # BUGFIX: this was checking 'Kind' when you meant 'Catalog'
        $noteCatalog = if ($null -ne $note.PSObject.Properties['Catalog']) {
            [string]$note.Catalog
        }

        $update = $this.Notes | Where-Object { $_.Note -eq $noteNote } | Select-Object -First 1
        
        if (-not $update) {
            Write-Warning "Note '$($noteNote)' not found in catalog '$($noteCatalog)'. No action taken."
            return
        }

        # Block updating remote notes (based on where the existing note lives)
        $existingCatalog = $this.GetCatalogObject($update.Catalog)
        if ($existingCatalog -and $existingCatalog.IsRemote) {
            Write-Warning "Cannot update note '$($update.Note)' because it belongs to remote catalog '$($update.Catalog)'. Remote notes are read-only."
            return
        }

        # Also block moving/updating into a remote catalog
        $targetCatalog = $this.GetCatalogObject($note.Catalog)
        if ($targetCatalog -and $targetCatalog.IsRemote) {
            Write-Warning "Cannot move note into remote catalog '$($note.Catalog)'. Remote catalogs are read-only."
            return
        }

        if ($update.Catalog -eq $noteCatalog) {
            $this.RemoveNote($noteNote, $noteCatalog, $false)
            $this.AddNote($note)
        }
        else {
            Write-Warning "Note '$($noteNote)' exists in catalog '$($update.Catalog)'. Cannot update note in different catalog at this time '$($noteCatalog)'. No action taken."
        }
    }

    [void] MoveNote([PSNote] $Note, [string] $DestinationCatalog, [bool] $Force) {

        if (-not $Note) { throw "Note is required." }
        if ([string]::IsNullOrWhiteSpace($Note.Catalog)) { throw "Input note must have a Catalog." }
        if ([string]::IsNullOrWhiteSpace($DestinationCatalog)) { throw "DestinationCatalog is required." }

        $sourceCatalogName = [string]$Note.Catalog

        if ($DestinationCatalog -eq $sourceCatalogName) {
            throw "DestinationCatalog is the same as SourceCatalog ('$sourceCatalogName'). Nothing to do."
        }

        $srcCatalog = $this.GetCatalogObject($sourceCatalogName)
        if (-not $srcCatalog) { throw "Source catalog '$sourceCatalogName' not found." }
        if ($srcCatalog.IsRemote) { throw "Cannot move notes from remote catalog '$sourceCatalogName'. Remote catalogs are read-only." }

        $dstCatalog = $this.GetCatalogObject($DestinationCatalog)
        if ($dstCatalog -and $dstCatalog.IsRemote) {
            throw "Cannot move notes into remote catalog '$DestinationCatalog'. Remote catalogs are read-only."
        }

        # Create destination catalog if missing (local)
        if (-not $dstCatalog) {
            $dstCatalog = [NoteCatalog]::new($DestinationCatalog)
            $dstCatalog.IsRemote = $false
            $this.Catalogs.Add($dstCatalog) | Out-Null
        }

        # Minimal identity: prefer Alias, else Note
        $keyAlias = [string]$Note.Alias
        $keyNote = [string]$Note.Note

        $sourceMatch = if (-not [string]::IsNullOrWhiteSpace($keyAlias)) {
            $srcCatalog.Notes | Where-Object { $_.Alias -eq $keyAlias } | Select-Object -First 1
        }
        else {
            $srcCatalog.Notes | Where-Object { $_.Note -eq $keyNote } | Select-Object -First 1
        }

        if (-not $sourceMatch) {
            throw "The provided note does not exist in source catalog '$sourceCatalogName' (by Alias/Note)."
        }

        # Destination conflict (Alias wins, else Note)
        $destConflict = $null
        if (-not [string]::IsNullOrWhiteSpace($keyAlias)) {
            $destConflict = $dstCatalog.Notes | Where-Object { $_.Alias -eq $keyAlias } | Select-Object -First 1
        }
        if (-not $destConflict -and -not [string]::IsNullOrWhiteSpace($keyNote)) {
            $destConflict = $dstCatalog.Notes | Where-Object { $_.Note -eq $keyNote } | Select-Object -First 1
        }

        if ($destConflict -and -not $Force) {
            throw "A note already exists in '$DestinationCatalog' with the same Alias/Note. Use -Force to overwrite."
        }

        # Preserve favorite status across the move (key includes Catalog)
        $wasFavorite = $this.IsFavorite($sourceMatch)
        if ($wasFavorite) { $this.RemoveFavorite($sourceMatch) }

        # Remove from source
        $null = $srcCatalog.Notes.Remove($sourceMatch)

        # Overwrite destination if forced
        if ($destConflict -and $Force) {
            $null = $dstCatalog.Notes.Remove($destConflict)
        }

        # Move (mutate the same object)
        $sourceMatch.Catalog = $DestinationCatalog
        $dstCatalog.Notes.Add($sourceMatch) | Out-Null

        # Persist both catalogs
        $srcCatalog.Save()
        $dstCatalog.Save()

        if ($wasFavorite) { $this.AddFavorite($sourceMatch) }

        # Refresh in-memory views (mirrors your Add/Remove patterns)
        $this.LoadCatalog($srcCatalog)
        $this.LoadCatalog($dstCatalog)
        $this.InitializeAliases()
    }

    hidden static [string] GetRemoteCacheRoot() {
        $root = Join-Path $env:PSNOTES_HOME 'remote'
        if (-not (Test-Path $root)) { $null = New-Item -Path $root -ItemType Directory -Force }
        return $root
    }

    hidden static [string] GetRemoteCacheFileName([string] $url) {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($url)
            $hash = ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join ''
            return "$hash.json"
        }
        finally { $sha.Dispose() }
    }

    [RemoteCatalogSource] RegisterRemoteCatalog([string] $name, [string] $Url) {
        if (-not $this.Config) { $this.Config = [NoteConfigStore]::new() }
        if (-not $this.Config.RemoteCatalogs) {
            $this.Config.RemoteCatalogs = [System.Collections.Generic.List[RemoteCatalogSource]]::new()
        }

        $existing = $this.Config.RemoteCatalogs | Where-Object { $_.Url -eq $Url } | Select-Object -First 1
        if ($existing) { return $existing }

        $cacheRoot = [NoteStore]::GetRemoteCacheRoot()
        $cacheFile = Join-Path $cacheRoot ([NoteStore]::GetRemoteCacheFileName($Url))
        $rel = [System.IO.Path]::GetRelativePath($env:PSNOTES_HOME, $cacheFile)

        $entry = [RemoteCatalogSource]::new($name, $Url, $rel)
        $this.Config.RemoteCatalogs.Add($entry) | Out-Null
        $this.Config.Save()
        $this.LoadRemoteCatalogs() # Optional: load immediately after registering
        return $entry
    }

    [void] SyncRemoteCatalogs() {
        if (-not $this.Config -or -not $this.Config.RemoteCatalogs) { return }

        foreach ($rc in $this.Config.RemoteCatalogs) {
            if (-not $rc.Enabled) { continue }
            if ([string]::IsNullOrWhiteSpace($rc.Url)) { continue }
            if ([string]::IsNullOrWhiteSpace($rc.CacheFile)) { continue }

            $cachePath = Join-Path $env:PSNOTES_HOME $rc.CacheFile
            $cacheDir = Split-Path $cachePath -Parent
            if (-not (Test-Path $cacheDir)) { $null = New-Item -Path $cacheDir -ItemType Directory -Force }

            try {
                $headers = @{}
                if (-not [string]::IsNullOrWhiteSpace($rc.ETag)) { $headers['If-None-Match'] = $rc.ETag }
                if (-not [string]::IsNullOrWhiteSpace($rc.LastModified)) { $headers['If-Modified-Since'] = $rc.LastModified }
                Write-Debug "Syncing remote catalog from $($rc.Url) with headers: $($headers | Out-String)"
                # Note: If the remote server supports ETag or Last-Modified, this will save bandwidth and be faster. If not, it will just download every time.
                # This is disabled for now because GIST was not playing nice with conditional requests, but you can enable it if your server supports it well.
                $resp = Invoke-WebRequest -Uri $rc.Url -UseBasicParsing -ErrorAction Stop

                $resp.Content | Set-Content -Path $cachePath -Encoding UTF8

                $rc.LastSync = (Get-Date).ToUniversalTime().ToString('o')
                if ($resp.Headers.ETag) { $rc.ETag = $resp.Headers.ETag }
                if ($resp.Headers.'Last-Modified') { $rc.LastModified = $resp.Headers.'Last-Modified' }
            }
            catch {
                if (Test-Path $cachePath) {
                    Write-Warning "Remote catalog unreachable ($($rc.Url)). Using cached version: $cachePath"
                }
                else {
                    Write-Warning "Remote catalog unreachable ($($rc.Url)) and no cached copy exists. Skipping."
                }
            }
        }

        $this.Config.Save()
    }

    [void] LoadRemoteCatalogs() {
        if (-not $this.Config -or -not $this.Config.RemoteCatalogs) { return }

        # Ensure cache is fresh first
        $this.SyncRemoteCatalogs()

        foreach ($rc in $this.Config.RemoteCatalogs) {
            if (-not $rc.Enabled) { continue }

            $cachePath = Join-Path $env:PSNOTES_HOME $rc.CacheFile
            if (-not (Test-Path $cachePath)) { continue }

            try {
                # NOTE: This assumes the remote JSON is in NoteCatalog format (or legacy array that ValidateNotes already tolerates)
                # If you want to support "bundle of catalogs", we can extend this to detect .Catalogs and split.
                if (-not [NoteCatalog]::VersionCheck($cachePath)) {
                    # version mismatch will warn later when opened; you can decide whether to block
                }

                $remoteCatalog = [NoteCatalog]::new($cachePath)
                $remoteCatalog.IsRemote = $true
                # Important: Load AFTER locals. Your existing duplicate behavior makes locals win.
                $this.LoadCatalog($remoteCatalog)
            }
            catch {
                Write-Warning "Failed to load remote catalog cache '$cachePath': $($_.Exception.Message)"
            }
        }
    }

    hidden [RemoteCatalogSource] RemoveRemoteCatalog([string] $Url, [bool] $RemoveCache) {

        if (-not $this.Config) {
            $this.Config = [NoteConfigStore]::new()
        }

        if (-not $this.Config.RemoteCatalogs -or $this.Config.RemoteCatalogs.Count -eq 0) {
            throw "No remote catalogs are registered."
        }

        $match = $this.Config.RemoteCatalogs |
        Where-Object { $_.Url -eq $Url } |
        Select-Object -First 1

        if (-not $match) {
            throw "Remote catalog not found: $Url"
        }

        # Remove from config
        $null = $this.Config.RemoteCatalogs.Remove($match)
        $this.Config.Save()

        # Optionally remove cache file
        if ($RemoveCache -and -not [string]::IsNullOrWhiteSpace($match.CacheFile)) {
            try {
                $cachePath = Join-Path $env:PSNOTES_HOME $match.CacheFile
                if (Test-Path $cachePath) {
                    Remove-Item -Path $cachePath -Force -ErrorAction Stop
                }
            }
            catch {
                Write-Warning "Removed remote catalog registration, but failed to delete cached file for '$Url': $($_.Exception.Message)"
            }
        }

        # If this remote catalog is currently loaded as a NoteCatalog in memory, remove it too
        # (Only if your Catalog objects for remote caches keep their Path equal to the cachePath.)
        try {
            if (-not [string]::IsNullOrWhiteSpace($match.CacheFile)) {
                $cachePath = Join-Path $env:PSNOTES_HOME $match.CacheFile
                $loadedCatalog = $this.Catalogs | Where-Object { $_.Path -eq $cachePath } | Select-Object -First 1

                if ($loadedCatalog) {
                    # Remove notes from store that came from that catalog
                    $notesToRemove = @($this.Notes | Where-Object { $_.Catalog -eq $loadedCatalog.Catalog })
                    foreach ($n in $notesToRemove) { $null = $this.Notes.Remove($n) }

                    # Remove the catalog object
                    $null = $this.Catalogs.Remove($loadedCatalog)

                    # Rebuild aliases / views
                    $this.InitializeAliases()
                }
            }
        }
        catch {
            # Don’t fail the operation if in-memory cleanup has issues
            Write-Warning "Remote catalog registration removed, but failed to clean up loaded state: $($_.Exception.Message)"
        }

        return $match
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