#requires -Version 5.1
# Pester 5.x tests for classes in NoteStore.class.ps1 (simple_console)
# Locate repo root (walk up until src/ exists)
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest

    # ---- Test sandbox ----
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME

    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("PSNotesTests_{0}" -f ([guid]::NewGuid().ToString('N')))
    $null = New-Item -Path $script:TestRoot -ItemType Directory -Force

    $env:PSNOTES_HOME = $script:TestRoot

    # Ensure the alias target exists if aliasing is not mocked for some reason
    function Get-PSNoteAlias { param() }
    $script:ClassPath = Join-Path $Global:TopLevel 'src\Classes\NoteStore.class.ps1'
    # Load classes
    . $script:ClassPath
}

AfterAll {
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
    if (Test-Path $script:TestRoot) {
        Remove-Item -Path $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe 'NoteStore.class.ps1 classes' {
    BeforeEach {
        # Clean PSNOTES_HOME between tests (but preserve root)
        Get-ChildItem -Path $env:PSNOTES_HOME -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        } | Out-Null

        # Recreate expected subdirs if tests want them
        $null = New-Item -Path $env:PSNOTES_HOME -ItemType Directory -Force
    }

    Describe 'PSNote' {
        It '5-parameter constructor sets defaults (Catalog=Default, Kind=Snippet, Run=$false)' {
            $n = [PSNote]::new('N1', 'Get-Date', 'd', 'a1', @('t1'))

            $n.Name    | Should -Be 'N1'
            $n.Snippet | Should -Be 'Get-Date'
            $n.Details | Should -Be 'd'
            $n.Alias   | Should -Be 'a1'
            $n.Tags    | Should -Be @('t1')
            $n.Catalog | Should -Be 'Default'
            $n.Run     | Should -BeFalse
            $n.Kind    | Should -Be ([PSNoteKind]::Snippet)
        }

        It '8-parameter constructor supports Script kind' {
            $n = [PSNote]::new('RunIt', [PSNoteKind]::Script, 'C:\x.ps1', 'd', 'run', @('s'), 'Cat1', $true)

            $n.Kind    | Should -Be ([PSNoteKind]::Script)
            $n.Snippet | Should -Be 'C:\x.ps1'
            $n.Catalog | Should -Be 'Cat1'
            $n.Run     | Should -BeTrue
        }

        It 'object constructor tolerates missing/invalid Kind and Run' {
            $obj = [pscustomobject]@{
                Name    = 'N'
                Snippet = 'S'
                Details = 'D'
                Alias   = 'A'
                Tags    = @()
                Catalog = 'C'
                Kind    = 'NotARealKind'
                Run     = 'notabool'
            }

            $n = [PSNote]::new($obj)
            $n.Kind | Should -Be ([PSNoteKind]::Snippet)
            $n.Run  | Should -BeFalse
        }

        It 'GetKey returns Catalog::Alias' {
            $n = [PSNote]::new('N', 'S', 'D', 'A', @())
            $n.Catalog = 'CatX'
            $n.GetKey() | Should -Be 'CatX::A'
        }

        It 'GetDisplayText adds (Script) for script notes' {
            $s = [PSNote]::new('N', [PSNoteKind]::Script, 'C:\x.ps1', 'D', 'A', @(), 'C', $false)
            $s.GetDisplayText() | Should -Be 'A (Script)'

            $p = [PSNote]::new('N2', 'Get-Process', 'D', 'gp', @())
            $p.GetDisplayText() | Should -Be 'gp'
        }
    }

    Describe 'NoteCatalog - ResolvePath/Open/Versioning/Validation' {
        It 'ResolvePath creates PSNOTES_HOME if needed and returns *.json' {
            Remove-Item -Path $env:PSNOTES_HOME -Recurse -Force
            $p = [NoteCatalog]::ResolvePath('MyCat', $env:PSNOTES_HOME)

            (Split-Path -Parent $p) | Should -Exist
            $p | Should -Match 'MyCat\.json$'
        }

        It 'Save writes current store version and ToJson excludes per-note Catalog property' {
            $cat = [NoteCatalog]::new($true)
            $cat.Path = [NoteCatalog]::ResolvePath('X')
            $cat.Catalog = 'X'
            $cat.Notes.Add([PSNote]::new('N1', 'S', 'D', 'A', @())) | Out-Null
            $cat.Notes[0].Catalog = 'X'
            $cat.Save()

            $json = Get-Content -Path $cat.Path -Raw -Encoding UTF8
            $data = $json | ConvertFrom-Json

            $data.StoreVersion | Should -Be ([NoteCatalog]::CurrentStoreVersion)
            $data.Catalog      | Should -Be 'X'
            $data.Notes.Count  | Should -Be 1

            # Stored notes intentionally exclude Catalog
            $data.Notes[0].PSObject.Properties.Name | Should -Not -Contain 'Catalog'
        }

        It 'Open refuses to load when StoreVersion mismatches' {
            $path = [NoteCatalog]::ResolvePath('BadVer')
            $bad = [pscustomobject]@{
                StoreVersion = 999
                Catalog      = 'BadVer'
                Notes        = @(
                    [pscustomobject]@{ Name = 'N'; Snippet = 'S'; Details = 'D'; Alias = 'A'; Tags = @() }
                )
            } | ConvertTo-Json -Depth 10

            $bad | Set-Content -Path $path -Encoding UTF8

            Mock -CommandName Write-Warning
            $c = [NoteCatalog]::new('BadVer')

            $c.Notes.Count | Should -Be 0
            Assert-MockCalled Write-Warning -Times 1
        }

        It 'VersionCheck returns true only for current store version' {
            $path = [NoteCatalog]::ResolvePath('VC')

            $ok = [pscustomobject]@{
                StoreVersion = [NoteCatalog]::CurrentStoreVersion
                Catalog      = 'VC'
                Notes        = @(
                    [pscustomobject]@{ Name = 'N'; Snippet = 'S'; Details = 'D'; Alias = 'A'; Tags = @() }
                )
            } | ConvertTo-Json -Depth 10
            $ok | Set-Content -Path $path -Encoding UTF8

            [NoteCatalog]::VersionCheck($path) | Should -BeTrue

            $bad = $ok | ConvertFrom-Json
            $bad.StoreVersion = 0
            ($bad | ConvertTo-Json -Depth 10) | Set-Content -Path $path -Encoding UTF8

            [NoteCatalog]::VersionCheck($path) | Should -BeFalse
        }

        It 'ValidateNotes flags legacy array format and missing Alias as warnings' {
            $path = [NoteCatalog]::ResolvePath('Legacy')

            @(
                [pscustomobject]@{ Note = 'N1'; Snippet = 'S1'; Details = 'D'; Tags = @('t') }  # no Alias
            ) | ConvertTo-Json -Depth 10 | Set-Content -Path $path -Encoding UTF8

            $r = [NoteCatalog]::ValidateNotes($path)
            $r.IsValid | Should -BeTrue
            $r.StoreVersion | Should -Be 'Legacy'
            ($r.Warnings -join "`n") | Should -Match 'Legacy note catalog format'
            ($r.Warnings -join "`n") | Should -Match "Missing 'Alias'"
        }

        It 'ValidateNotes fails for empty file' {
            $path = [NoteCatalog]::ResolvePath('Empty')
            '' | Set-Content -Path $path -Encoding UTF8

            $r = [NoteCatalog]::ValidateNotes($path)
            $r.IsValid | Should -BeFalse
            ($r.Errors -join "`n") | Should -Match 'File is empty'
        }
    }

    Describe 'NoteCatalog - AtomicSaveWithBackup' {
        It 'creates backup when overwriting and keeps only last 10 backups' {
            $path = [NoteCatalog]::ResolvePath('B')
            'one' | Set-Content -Path $path -Encoding UTF8

            # Write 12 times -> backups should be trimmed to 10
            1..12 | ForEach-Object {
                [NoteCatalog]::AtomicSaveWithBackup($path, "content $_")
            }

            $backupDir = Join-Path $env:PSNOTES_HOME 'backups'
            $backupDir | Should -Exist

            $fileName = [System.IO.Path]::GetFileName($path)
            $bak = Get-ChildItem -Path $backupDir -Filter "$fileName.*.bak" -File -ErrorAction SilentlyContinue
            $bak.Count | Should -BeLessOrEqual 10

            (Get-Content -Path $path -Raw -Encoding UTF8) | Should -Match 'content 12'
        }
    }

    Describe 'NoteCatalog - Migrate' {
        It 'migrates legacy array to current object format and creates backup artifacts' {
            $legacyPath = [NoteCatalog]::ResolvePath('LegacyToMigrate')
            @(
                [pscustomobject]@{ Name = 'N1'; Snippet = 'S1'; Details = 'D1'; Alias = 'A1'; Tags = @('t1') },
                [pscustomobject]@{ Name = 'N2'; Snippet = 'S2'; Details = 'D2'; Alias = 'A2'; Tags = @() }
            ) | ConvertTo-Json -Depth 10 | Set-Content -Path $legacyPath -Encoding UTF8

            $m = [NoteCatalog]::Migrate($legacyPath, $true)

            $m.Notes.Count | Should -Be 2
            $m.Notes[0].Catalog | Should -Be 'LegacyToMigrate'

            $backupDir = Join-Path $env:PSNOTES_HOME 'backups'
            $backupDir | Should -Exist

            # Should have created at least one pre-migration backup
            $fileName = [System.IO.Path]::GetFileName($legacyPath)
            (Get-ChildItem -Path $backupDir -Filter "$fileName.pre-migration.*.bak" -File -ErrorAction SilentlyContinue | Measure-Object).Count |
            Should -BeGreaterThan 0
        }
    }

    Describe 'NoteStore - local catalogs, add/remove/update, duplicate behavior' {
        BeforeEach {
            Mock -CommandName Set-Alias
            Mock -CommandName Write-Warning
            Mock -CommandName Write-Verbose
            Mock -CommandName Write-Debug
        }

        It 'constructor loads local catalogs from PSNOTES_HOME (current format)' {
            $path = [NoteCatalog]::ResolvePath('Cat1')
            $obj = [pscustomobject]@{
                StoreVersion = [NoteCatalog]::CurrentStoreVersion
                Catalog      = 'Cat1'
                Notes        = @(
                    [pscustomobject]@{ Name = 'N1'; Snippet = 'S1'; Details = 'D1'; Alias = 'a1'; Tags = @('t') }
                )
            } | ConvertTo-Json -Depth 10
            $obj | Set-Content -Path $path -Encoding UTF8

            $s = [NoteStore]::new()

            $s.Catalogs.Catalog | Should -Contain 'Cat1'
            ($s.Notes | Where-Object Alias -eq 'a1' | Measure-Object).Count | Should -Be 1

            Assert-MockCalled Set-Alias -Times 1 -Exactly
        }

        It 'LoadCatalog skips duplicate alias when already present from different catalog' {
            $s = [NoteStore]::new()

            $c1 = [NoteCatalog]::new($true); $c1.Catalog = 'C1'; $c1.Path = [NoteCatalog]::ResolvePath('C1')
            $c2 = [NoteCatalog]::new($true); $c2.Catalog = 'C2'; $c2.Path = [NoteCatalog]::ResolvePath('C2')

            $n1 = [PSNote]::new('N1', 'S', 'D', 'dup', @()); $n1.Catalog = 'C1'
            $n2 = [PSNote]::new('N2', 'S', 'D', 'dup', @()); $n2.Catalog = 'C2'

            $c1.Notes.Add($n1) | Out-Null
            $c2.Notes.Add($n2) | Out-Null

            $s.LoadCatalog($c1)
            $s.LoadCatalog($c2)

            ($s.Notes | Where-Object Alias -eq 'dup' | Measure-Object).Count | Should -Be 1
            Assert-MockCalled Write-Warning -Times 1
        }

        It 'AddNote blocks adding into remote catalog' {
            $s = [NoteStore]::new()

            $remote = [NoteCatalog]::new($true)
            $remote.Catalog = 'Remote1'
            $remote.Path = 'x'
            $remote.IsRemote = $true
            $s.Catalogs.Add($remote) | Out-Null

            $n = [PSNote]::new('N', 'S', 'D', 'a', @()); $n.Catalog = 'Remote1'
            $s.AddNote($n)

            ($s.Notes | Where-Object Name -eq 'N' | Measure-Object).Count | Should -Be 0
            Assert-MockCalled Write-Warning -Times 1
        }

        It 'RemoveNote blocks removing from remote catalog' {
            $s = [NoteStore]::new()

            $remote = [NoteCatalog]::new($true)
            $remote.Catalog = 'Remote1'
            $remote.Path = 'x'
            $remote.IsRemote = $true

            $n = [PSNote]::new('N', 'S', 'D', 'a', @()); $n.Catalog = 'Remote1'
            $remote.Notes.Add($n) | Out-Null

            $s.Catalogs.Add($remote) | Out-Null
            $s.Notes.Add($n) | Out-Null

            $s.RemoveNote('N', 'Remote1')
            ($s.Notes | Where-Object Name -eq 'N' | Measure-Object).Count | Should -Be 1
            Assert-MockCalled Write-Warning -Times 1
        }

        It 'UpdateNote blocks updating remote notes (existing lives in remote)' {
            $s = [NoteStore]::new()

            $remote = [NoteCatalog]::new($true)
            $remote.Catalog = 'Remote1'
            $remote.Path = 'x'
            $remote.IsRemote = $true

            $existing = [PSNote]::new('N', 'S', 'D', 'a', @()); $existing.Catalog = 'Remote1'
            $remote.Notes.Add($existing) | Out-Null

            $s.Catalogs.Add($remote) | Out-Null
            $s.Notes.Add($existing) | Out-Null

            $updated = [PSNote]::new('N', 'S2', 'D2', 'a', @()); $updated.Catalog = 'Remote1'
            $s.UpdateNote($updated)

            ($s.Notes | Where-Object Name -eq 'N' | Select-Object -First 1).Snippet | Should -Be 'S'
            Assert-MockCalled Write-Warning -Times 1
        }
    }

    Describe 'NoteStore - favorites + MoveNote' {
        BeforeEach {
            Mock -CommandName Set-Alias
            Mock -CommandName Write-Warning
            Mock -CommandName Write-Verbose
            Mock -CommandName Write-Debug
        }

        It 'AddFavorite/IsFavorite/GetFavorites/RemoveFavorite works' {
            $s = [NoteStore]::new()

            $c = [NoteCatalog]::new($true); $c.Catalog = 'C1'; $c.Path = [NoteCatalog]::ResolvePath('C1')
            $n = [PSNote]::new('N', 'S', 'D', 'a', @()); $n.Catalog = 'C1'
            $c.Notes.Add($n) | Out-Null
            $s.LoadCatalog($c)

            $s.IsFavorite($n) | Should -BeFalse
            $s.AddFavorite($n)
            $s.IsFavorite($n) | Should -BeTrue

            $f = $s.GetFavorites()
            $f.Count | Should -Be 1
            $f[0].Name | Should -Be 'N'

            $s.RemoveFavorite($n)
            $s.IsFavorite($n) | Should -BeFalse
        }

        It 'MoveNote preserves favorite status and supports -Force overwrite' {
            $s = [NoteStore]::new()

            $src = [NoteCatalog]::new($true); $src.Catalog = 'Src'; $src.Path = [NoteCatalog]::ResolvePath('Src')
            $dst = [NoteCatalog]::new($true); $dst.Catalog = 'Dst'; $dst.Path = [NoteCatalog]::ResolvePath('Dst')

            $n = [PSNote]::new('N', 'S', 'D', 'a', @()); $n.Catalog = 'Src'
            $src.Notes.Add($n) | Out-Null

            # Conflict in destination
            $conflict = [PSNote]::new('Other', 'S', 'D', 'a', @()); $conflict.Catalog = 'Dst'
            $dst.Notes.Add($conflict) | Out-Null

            $s.LoadCatalog($src)
            $s.LoadCatalog($dst)

            $s.AddFavorite($n)
            $s.IsFavorite($n) | Should -BeTrue

            { $s.MoveNote($n, 'Dst', $false) } | Should -Throw

            $s.MoveNote($n, 'Dst', $true)

            # After move:
            $n.Catalog | Should -Be 'Dst'
            $s.IsFavorite($n) | Should -BeTrue

            # Destination should now contain moved note (alias 'a')
            ($s.Catalogs | Where-Object Catalog -eq 'Dst' | Select-Object -First 1).Notes |
            Where-Object Alias -eq 'a' |
            Select-Object -First 1 |
            ForEach-Object { $_.Name } | Should -Be 'N'
        }
    }

    Describe 'NoteStore - remote catalogs (mocked web)' {
        BeforeEach {
            Mock -CommandName Set-Alias
            Mock -CommandName Write-Warning
            Mock -CommandName Write-Verbose
            Mock -CommandName Write-Debug
        }

        It 'RegisterRemoteCatalog stores config and creates stable cache file path' {
            # mock web so LoadRemoteCatalogs/SyncRemoteCatalogs doesn’t do real network
            Mock -CommandName Invoke-WebRequest -MockWith {
                [pscustomobject]@{
                    Content = ([pscustomobject]@{
                            StoreVersion = [NoteCatalog]::CurrentStoreVersion
                            Catalog      = 'RemoteIgnored'
                            Notes        = @(
                                [pscustomobject]@{ Name = 'N'; Snippet = 'S'; Details = 'D'; Alias = 'a'; Tags = @() }
                            )
                        } | ConvertTo-Json -Depth 10)
                    Headers = @{ ETag = '"x"'; 'Last-Modified' = 'Wed, 01 Jan 2025 00:00:00 GMT' }
                }
            }

            $s = [NoteStore]::new()
            $entry = $s.RegisterRemoteCatalog('MyRemote', 'https://example.invalid/catalog.json')

            $entry.Name | Should -Be 'MyRemote'
            $entry.Url  | Should -Be 'https://example.invalid/catalog.json'
            $entry.CacheFile | Should -Match '^remote\\.+\.json$'

            # Config file should exist
            (Join-Path $env:PSNOTES_HOME 'config\psnoteconfigstore.json') | Should -Exist
        }

        It 'LoadRemoteCatalogs loads cache as IsRemote and overrides catalog name with config Name' {
            Mock -CommandName Invoke-WebRequest -MockWith {
                [pscustomobject]@{
                    Content = ([pscustomobject]@{
                            StoreVersion = [NoteCatalog]::CurrentStoreVersion
                            Catalog      = 'RemoteCatalogName'
                            Notes        = @(
                                [pscustomobject]@{ Name = 'N1'; Snippet = 'S1'; Details = 'D1'; Alias = 'r1'; Tags = @() }
                            )
                        } | ConvertTo-Json -Depth 10)
                    Headers = @{ ETag = '"x"' }
                }
            }

            $s = [NoteStore]::new()
            $null = $s.RegisterRemoteCatalog('FriendlyRemote', 'https://example.invalid/r.json')

            # After register it calls LoadRemoteCatalogs; verify remote loaded
            $rc = $s.Catalogs | Where-Object Catalog -eq 'FriendlyRemote' | Select-Object -First 1
            $rc | Should -Not -BeNullOrEmpty
            $rc.IsRemote | Should -BeTrue

            ($s.Notes | Where-Object Catalog -eq 'FriendlyRemote' | Select-Object -First 1).Alias | Should -Be 'r1'
        }

        It 'RemoveRemoteCatalog throws when none registered' {
            $s = [NoteStore]::new()
            { $s.RemoveRemoteCatalog('https://nope', $false, $false) } | Should -Throw
        }

        It 'RemoveRemoteCatalog -ConvertToLocal writes local catalog and unregisters remote' {
            # Prepare remote registration + cached file
            Mock -CommandName Invoke-WebRequest -MockWith {
                [pscustomobject]@{
                    Content = ([pscustomobject]@{
                            StoreVersion = [NoteCatalog]::CurrentStoreVersion
                            Catalog      = 'RemoteCatalogName'
                            Notes        = @(
                                [pscustomobject]@{ Name = 'N1'; Snippet = 'S1'; Details = 'D1'; Alias = 'r1'; Tags = @() }
                            )
                        } | ConvertTo-Json -Depth 10)
                    Headers = @{ }
                }
            }

            $s = [NoteStore]::new()
            $entry = $s.RegisterRemoteCatalog('FriendlyRemote', 'https://example.invalid/r.json')

            # Force a cache presence (register already syncs; but be explicit)
            $cachePath = Join-Path $env:PSNOTES_HOME $entry.CacheFile
            $cachePath | Should -Exist

            # Convert to local -> should create FriendlyRemote.json locally
            $removed = $s.RemoveRemoteCatalog($entry.Url, $true, $true)
            $removed.Url | Should -Be $entry.Url

            $localPath = [NoteCatalog]::ResolvePath('FriendlyRemote')
            $localPath | Should -Exist

            # Should no longer be registered
            ($s.Config.RemoteCatalogs | Where-Object Url -eq $entry.Url | Measure-Object).Count | Should -Be 0
        }
    }
}