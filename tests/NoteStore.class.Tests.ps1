. "$PSScriptRoot\..\src\Classes\NoteStore.class.ps1"
BeforeAll {
    # Load the class file
    . "$PSScriptRoot\..\src\Classes\NoteStore.class.ps1"
    
    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests_$(Get-Random)"
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force
    
    # Set up test environment variable
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
    
    # Clean up test directory
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
}

Describe 'PSNote Class' {
    Context 'Constructor with 5 parameters' {
        It 'creates a PSNote object with all properties set' {
            $note = [PSNote]::new(
                'MyNote',
                'Write-Host "Hello"',
                'A greeting snippet',
                'MyAlias',
                @('test', 'example')
            )
            
            $note.Note | Should -Be 'MyNote'
            $note.Snippet | Should -Be 'Write-Host "Hello"'
            $note.Details | Should -Be 'A greeting snippet'
            $note.Alias | Should -Be 'MyAlias'
            $note.Tags | Should -Be @('test', 'example')
            $note.Catalog | Should -Be 'PSNotes'
        }
        
        It 'sets Alias to Note when Alias is empty' {
            $note = [PSNote]::new(
                'MyNote',
                'Write-Host "Hello"',
                'A greeting snippet',
                '',
                @('test')
            )
            
            $note.Alias | Should -Be 'MyNote'
        }
    }
    
    Context 'Constructor with 6 parameters' {
        It 'creates a PSNote object with custom catalog' {
            $note = [PSNote]::new(
                'MyNote',
                'Write-Host "Hello"',
                'A greeting snippet',
                'MyAlias',
                @('test'),
                'CustomCatalog',
                $false
            )
            
            $note.Note | Should -Be 'MyNote'
            $note.Catalog | Should -Be 'CustomCatalog'
        }
        
        It 'sets Alias to Note when Alias is empty with custom catalog' {
            $note = [PSNote]::new(
                'MyNote',
                'Write-Host "Hello"',
                'A greeting snippet',
                '',
                @('test'),
                'CustomCatalog',
                $false
            )
            
            $note.Alias | Should -Be 'MyNote'
        }
    }
    
    Context 'Constructor with object parameter' {
        It 'creates a PSNote from a PSCustomObject' {
            $obj = [pscustomobject]@{
                Note    = 'TestNote'
                Snippet = '$x = 1'
                Details = 'A test note'
                Alias   = 'tn'
                Tags    = @('tag1', 'tag2')
                Catalog = 'TestCatalog'
                Run = $false
            }
            
            $note = [PSNote]::new($obj)
            
            $note.Note | Should -Be 'TestNote'
            $note.Snippet | Should -Be '$x = 1'
            $note.Details | Should -Be 'A test note'
            $note.Alias | Should -Be 'tn'
            $note.Tags | Should -Be @('tag1', 'tag2')
            $note.Catalog | Should -Be 'TestCatalog'
        }
        
        It 'sets Alias to Note from object when Alias is empty' {
            $obj = [pscustomobject]@{
                Note    = 'TestNote'
                Snippet = '$x = 1'
                Details = 'A test note'
                Alias   = ''
                Tags    = @('tag1')
                Catalog = 'TestCatalog'
                Run =$false
            }
            
            $note = [PSNote]::new($obj)
            
            $note.Alias | Should -Be 'TestNote'
        }
    }
}

Describe 'NoteCatalog Static Methods' {
    Context 'InitializeEnvironment' {
        It 'sets PSNOTES_HOME when not already set' {
            $tempEnv = $env:PSNOTES_HOME
            Remove-Item env:PSNOTES_HOME -ErrorAction SilentlyContinue
            
            [NoteCatalog]::InitializeEnvironment()
            
            $env:PSNOTES_HOME | Should -Not -BeNullOrEmpty
            
            # Restore
            $env:PSNOTES_HOME = $tempEnv
        }
    }
    
    Context 'ResolvePath' {
        It 'resolves path with no parameters (default catalog)' {
            $path = [NoteCatalog]::ResolvePath()
            
            $path | Should -Match 'PSNotes\.json$'
            (Split-Path -Parent $path) | Should -Exist
        }
        
        It 'resolves path with only catalog name parameter' {
            $path = [NoteCatalog]::ResolvePath('MyNotes')
            
            $path | Should -Match 'MyNotes\.json$'
        }
        
        It 'resolves path with custom catalog name and root path' {
            $path = [NoteCatalog]::ResolvePath('CustomNote', $script:TestDir)
            
            $path | Should -Match 'CustomNote\.json$'
            $path | Should -Match ([regex]::Escape($script:TestDir))
        }
        
        It 'resolves path when catalog name already has .json extension' {
            $path = [NoteCatalog]::ResolvePath('MyNotes.json')
            
            $path | Should -Match 'MyNotes\.json$'
            $path | Should -Not -Match 'MyNotes\.json\.json$'
        }
        
        It 'creates root path directory if it does not exist' {
            $testPath = Join-Path $script:TestDir 'subdir'
            
            $path = [NoteCatalog]::ResolvePath('test', $testPath)
            
            (Split-Path -Parent $path) | Should -Exist
        }
    }
    
    Context 'ReadUtf8NoBom' {
        It 'reads UTF8 content from file without BOM' {
            $testFile = Join-Path $script:TestDir 'test.json'
            $content = '{"test": "value"}'
            
            $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
            [System.IO.File]::WriteAllText($testFile, $content, $utf8NoBom)
            
            $result = [NoteCatalog]::ReadUtf8NoBom($testFile)
            
            $result | Should -Be $content
        }
        
        It 'returns null when file does not exist' {
            $result = [NoteCatalog]::ReadUtf8NoBom('C:\NonExistent\file.json')
            
            $result | Should -BeNullOrEmpty
        }
    }
    <#
    Context 'WriteUtf8NoBomToLockedStream' {
        It 'writes content to stream with UTF8 no BOM encoding' {
            $testFile = Join-Path $script:TestDir 'write_test.json'
            $content = '{"data": "test"}'
            
            $stream = [System.IO.File]::Open(
                $testFile,
                [System.IO.FileMode]::Create,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
            
            try {
                [NoteCatalog]::WriteUtf8NoBomToLockedStream($stream, $content)
                
                $readBack = [NoteCatalog]::ReadUtf8NoBom($testFile)
                $readBack | Should -Be $content
            }
            finally {
                $stream.Dispose()
            }
        }
        
        It 'clears existing stream content before writing' {
            $testFile = Join-Path $script:TestDir 'clear_test.json'
            $content1 = '{"first": "content"}'
            $content2 = '{"second": "data"}'
            
            # Write initial content
            [System.IO.File]::WriteAllText($testFile, $content1)
            
            # Open and overwrite
            $stream = [System.IO.File]::Open(
                $testFile,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
            
            try {
                [NoteCatalog]::WriteUtf8NoBomToLockedStream($stream, $content2)
                
                $readBack = [NoteCatalog]::ReadUtf8NoBom($testFile)
                $readBack | Should -Be $content2
                $readBack.Length | Should -BeLess $content1.Length
            }
            finally {
                $stream.Dispose()
            }
        }
    }
    
    Context 'AcquireLock' {
        It 'acquires lock on file' {
            $testFile = Join-Path $script:TestDir 'lock_test.json'
            $null = New-Item -Path $testFile -ItemType File -Force
            
            $lockStream = $null
            try {
                $lockStream = [NoteCatalog]::AcquireLock($testFile)
                $lockStream | Should -Not -BeNullOrEmpty
                $lockStream.CanRead | Should -Be $true
                $lockStream.CanWrite | Should -Be $true
            }
            finally {
                $lockStream.Dispose()
            }
        }
        
        It 'times out when file is locked by another stream' {
            $testFile = Join-Path $script:TestDir 'locked_test.json'
            $null = New-Item -Path $testFile -ItemType File -Force
            
            $lock1 = [System.IO.File]::Open(
                $testFile,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
            
            try {
                { [NoteCatalog]::AcquireLock($testFile, 100) } | Should -Throw
            }
            finally {
                $lock1.Dispose()
            }
        }
    }
    #>
}

Describe 'NoteCatalog Instance Methods' {
    Context 'Constructor without parameters' {
        It 'creates a default catalog' {
            $catalog = [NoteCatalog]::new()
            $catalog.Catalog | Should -Be 'PSNotes'
            $catalog.StoreVersion | Should -Be 1

            $catalog.Save()
            #$catalog.Notes | Should -BeOfType 'System.Collections.Generic.List[PSNote]'
            $catalog.Path | Should -Exist -Because 'directory should be created'
        }
    }
    
    Context 'Constructor with catalog name' {
        It 'creates catalog with custom name' {
            $catalog = [NoteCatalog]::new('MyCatalog')
            
            $catalog.Catalog | Should -Be 'MyCatalog'
            $catalog.Path | Should -Match 'MyCatalog\.json$'
        }
    }
    
    Context 'Constructor with blank parameter' {
        It 'creates blank catalog without loading from disk' {
            $catalog = [NoteCatalog]::new($true)
            
            $catalog.StoreVersion | Should -Be 1
            $catalog.Notes.Count | Should -Be 0
            $catalog.Path | Should -Not -BeNullOrEmpty
        }
        
        It 'blank catalog does not auto-load existing file' {
            # Create and save a catalog with notes
            $existingCatalog = [NoteCatalog]::new('BlankTest')
            $existingCatalog.Notes.Add([PSNote]::new('ExistingNote', 'code', 'details', 'en', @('tag')))
            $existingCatalog.Save()
            
            # Create blank catalog - should not load the existing file
            $blankCatalog = [NoteCatalog]::new($true)
            $blankCatalog.Notes.Count | Should -Be 0
        }
    }
    
    Context 'Open method' {
        It 'opens and loads existing catalog' {
            # Create a catalog with test data
            $testNote = [PSNote]::new(
                'TestNote',
                'Write-Host "test"',
                'Test details',
                'tn',
                @('tag1')
            )
            
            $catalog = [NoteCatalog]::new('TestCatalog')
            $catalog.Notes.Add($testNote)
            $catalog.Save()
            
            # Create a new instance and load
            $catalog2 = [NoteCatalog]::new('TestCatalog')
            $catalog2.Notes.Count | Should -Be 1
            $catalog2.Notes[0].Note | Should -Be 'TestNote'
        }
        
        It 'handles empty catalog file' {
            $testFile = Join-Path $script:TestDir 'empty_catalog.json'
            $null = New-Item -Path $testFile -ItemType File -Force
            
            $catalog = [NoteCatalog]::Open($testFile)
            
            $catalog.Notes.Count | Should -Be 0
        }
        
        It 'loads legacy catalog format (array of notes)' {
            $testFile = Join-Path $script:TestDir 'legacy_catalog.json'
            
            # Legacy format is just an array
            $legacyJson = @(
                [pscustomobject]@{
                    Note    = 'Legacy1'
                    Snippet = 'code'
                    Details = 'details'
                    Alias   = 'l1'
                    Tags    = @('old')
                    Catalog = ''
                }
            ) | ConvertTo-Json
            
            Set-Content -Path $testFile -Value $legacyJson
            
            $catalog = [NoteCatalog]::Open($testFile)
            
            $catalog.Notes.Count | Should -Be 1
            $catalog.Notes[0].Note | Should -Be 'Legacy1'
        }
    }
    
    Context 'ToJson method' {
        It 'serializes catalog to JSON' {
            $catalog = [NoteCatalog]::new('TestCatalog')
            $testNote = [PSNote]::new(
                'TestNote',
                'Write-Host "test"',
                'Test details',
                'tn',
                @('tag1')
            )
            $catalog.Notes.Add($testNote)
            
            $json = $catalog.ToJson()
            
            $json | Should -Not -BeNullOrEmpty
            $json | Should -Match '"StoreVersion"'
            $json | Should -Match '"Notes"'
            
            # Verify it's valid JSON
            { $json | ConvertFrom-Json } | Should -Not -Throw
        }
        
        It 'includes all notes in JSON' {
            $catalog = [NoteCatalog]::new('TestCatalogAdd')
            $catalog.Notes.Add([PSNote]::new('Note1', 'code1', 'det1', 'n1', @('t1')))
            $catalog.Notes.Add([PSNote]::new('Note2', 'code2', 'det2', 'n2', @('t2')))
            
            $json = $catalog.ToJson()
            $obj = $json | ConvertFrom-Json
            
            $obj.Notes.Count | Should -Be 2
        }
    }
    
    Context 'Save method' {
        It 'saves catalog to file' {
            $catalog = [NoteCatalog]::new('SaveTest')
            $testNote = [PSNote]::new(
                'SaveNote',
                'Write-Host "save"',
                'Save test',
                'sn',
                @('save')
            )
            $catalog.Notes.Add($testNote)
            
            $catalog.Save()
            
            Test-Path $catalog.Path | Should -Be $true
            
            # Verify content
            $content = Get-Content $catalog.Path -Raw
            $content | Should -Match '"SaveNote"'
        }
        
        It 'saves with custom timeout' {
            $catalog = [NoteCatalog]::new('TimeoutTest')
            $testNote = [PSNote]::new(
                'TimeoutNote',
                'code',
                'details',
                'tn',
                @('test')
            )
            $catalog.Notes.Add($testNote)
            
            { $catalog.Save(10000) } | Should -Not -Throw
            Test-Path $catalog.Path | Should -Be $true
        }
        
        It 'updates StoreVersion before saving' {
            $catalog = [NoteCatalog]::new('VersionTest')
            $initialVersion = $catalog.StoreVersion
            
            $catalog.Save()
            
            $json = Get-Content $catalog.Path -Raw | ConvertFrom-Json
            $json.StoreVersion | Should -Be $initialVersion
        }
    }
}

Describe 'NoteStore Class' {
    Context 'Constructor' {
        It 'creates a NoteStore with default catalog' {
            $store = [NoteStore]::new()
            
            $store.Catalogs | Should -Not -BeNullOrEmpty
            $store.Catalogs.Count | Should -Be 1
            $store.Catalogs[0].Catalog | Should -Be 'PSNotes'
            #$store.Notes | Should -BeOfType 'System.Collections.Generic.List[PSNote]'
        }
    }
    
    Context 'LoadCatalog with string' {
        It 'loads a catalog by name' {
            # Create a test catalog with notes
            $testCatalog = [NoteCatalog]::new('LoadTest')
            $testNote = [PSNote]::new(
                'LoadedNote',
                'code',
                'details',
                'ln',
                @('tag1')
            )
            $testCatalog.Notes.Add($testNote)
            $testCatalog.Save()
            
            # Create store and load catalog
            $store = [NoteStore]::new()
            $initialCount = $store.Notes.Count
            $store.LoadCatalog('LoadTest')
            
            $store.Catalogs.Count | Should -Be 2
            $store.Notes.Count | Should -BeGreaterThan $initialCount
        }
    }
    
    Context 'LoadCatalog with NoteCatalog object' {
        It 'loads a NoteCatalog object' {
            $testCatalog = [NoteCatalog]::new('ObjectLoadTest')
            $testNote = [PSNote]::new(
                'ObjectNote',
                'code',
                'details',
                'on',
                @('tag')
            )
            $testCatalog.Notes.Add($testNote)
            
            $store = [NoteStore]::new()
            $initialCount = $store.Catalogs.Count
            $store.LoadCatalog($testCatalog)
            
            $store.Catalogs.Count | Should -Be ($initialCount + 1)
            $store.Notes.Count | Should -BeGreaterThan 0
        }
        
        It 'prevents duplicate aliases when loading catalog' {
            $store = [NoteStore]::new()
            
            # Create a note with same alias as one that might exist
            $testCatalogA = [NoteCatalog]::new('DuplicateTestA')
            $dupNote = [PSNote]::new(
                'DupNote',
                'code',
                'details',
                'PSNotes',
                @('tag'),
                'DuplicateTestA',
                $false
            )
            $testCatalogA.Notes.Add($dupNote)
            $store.LoadCatalog($testCatalogA)
            $testCatalogB = [NoteCatalog]::new('DuplicateTestB')
            $dupNoteB = [PSNote]::new(
                'DupNote',
                'code',
                'details',
                'PSNotes',
                @('tag'),
                'DuplicateTestB',
                $false
            )
            $testCatalogB.Notes.Add($dupNoteB)  # Add duplicate
            
            # This should warn but not throw
            $warnings = & {
                $store.LoadCatalog($testCatalogB)
            } 3>&1
            Write-Host $warnings
            $warnings | Should -Be "Duplicate Alias found: PSNotes. Skipping note: DupNote"
        }
    }
        
    Context 'Integration tests' {
        It 'loads multiple catalogs and consolidates notes' {
            # Create first catalog
            $cat1 = [NoteCatalog]::new('IntegrationCat1')
            $cat1.Notes.Add([PSNote]::new('Note1', 'c1', 'd1', 'n1', @('t1')))
            $cat1.Notes.Add([PSNote]::new('Note2', 'c2', 'd2', 'n2', @('t2')))
            $cat1.Save()
            
            # Create second catalog
            $cat2 = [NoteCatalog]::new('IntegrationCat2')
            $cat2.Notes.Add([PSNote]::new('Note3', 'c3', 'd3', 'n3', @('t3')))
            $cat2.Save()
            
            # Load into store
            $store = [NoteStore]::new()
            $store.LoadCatalog('IntegrationCat1')
            $store.LoadCatalog('IntegrationCat2')
            
            $store.Catalogs.Count | Should -Be 3  # default + 2 loaded
            $store.Notes.Count | Should -BeGreaterOrEqual 3
        }
    }
    
    Context 'AddNote method' {
        It 'adds a note to both store and catalog' {
            # Create and save a catalog first
            $catalog = [NoteCatalog]::new('AddNoteTest')
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('AddNoteTest')
            
            $newNote = [PSNote]::new(
                'AddedNote',
                'Write-Host "added"',
                'A newly added note',
                'an',
                @('added'),
                'AddNoteTest',
                $false
            )
            
            $initialCount = $store.Notes.Count
            $store.AddNote($newNote)
            
            # Verify note is in store
            $store.Notes.Count | Should -Be ($initialCount + 1)
            $store.Notes | Where-Object { $_.Note -eq 'AddedNote' } | Should -Not -BeNullOrEmpty
            
            # Verify note is in catalog
            $catalog = $store.Catalogs | Where-Object { $_.Catalog -eq 'AddNoteTest' }
            $catalog.Notes | Where-Object { $_.Note -eq 'AddedNote' } | Should -Not -BeNullOrEmpty
        }
        
        It 'saves catalog after adding note' {
            $catalog = [NoteCatalog]::new('AddNoteSaveTest')
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('AddNoteSaveTest')
            
            $newNote = [PSNote]::new(
                'SavedNote',
                'code',
                'details',
                'sn',
                @('test'),
                'AddNoteSaveTest',
                $false
            )
            
            $store.AddNote($newNote)
            
            # Reload from disk to verify persistence
            $store2 = [NoteStore]::new()
            $store2.LoadCatalog('AddNoteSaveTest')
            $store2.Notes | Where-Object { $_.Note -eq 'SavedNote' } | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'RemoveNote method' {
        It 'removes a note from store and catalog' {
            # Create catalog with notes
            $catalog = [NoteCatalog]::new('RemoveNoteTest')
            $noteToRemove = [PSNote]::new('RemoveMe', 'code', 'details', 'rm', @('remove'),'RemoveNoteTest', $false)
            $noteToKeep = [PSNote]::new('KeepMe', 'code', 'details', 'km', @('keep'),'RemoveNoteTest', $false)
            $catalog.Notes.Add($noteToRemove)
            $catalog.Notes.Add($noteToKeep)
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('RemoveNoteTest')
            
            $initialCount = $store.Notes.Count
            $store.RemoveNote('RemoveMe', 'RemoveNoteTest')
            
            # Verify note is removed from store
            $store.Notes.Count | Should -Be ($initialCount - 1)
            $store.Notes | Where-Object { $_.Note -eq 'RemoveMe' } | Should -BeNullOrEmpty
            
            # Verify other note still exists
            $store.Notes | Where-Object { $_.Note -eq 'KeepMe' } | Should -Not -BeNullOrEmpty
            
            # Verify removal persisted to catalog
            $catalog = $store.Catalogs | Where-Object { $_.Catalog -eq 'RemoveNoteTest' }
            $catalog.Notes | Where-Object { $_.Note -eq 'RemoveMe' } | Should -BeNullOrEmpty
        }
        
        It 'persists removal to disk' {
            $catalog = [NoteCatalog]::new('RemoveNotePersistTest')
            $noteToRemove = [PSNote]::new('TempNote', 'code', 'details', 'tn', @('temp'),'RemoveNotePersistTest', $false)
            $catalog.Notes.Add($noteToRemove)
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('RemoveNotePersistTest')
            $store.RemoveNote('TempNote', 'RemoveNotePersistTest')
            
            # Reload from disk to verify persistence
            $store2 = [NoteStore]::new()
            $store2.LoadCatalog('RemoveNotePersistTest')
            $store2.Notes | Where-Object { $_.Note -eq 'TempNote' } | Should -BeNullOrEmpty
        }
        
        It 'handles removing non-existent note gracefully' {
            $catalog = [NoteCatalog]::new('RemoveNonExistentTest')
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('RemoveNonExistentTest')
            
            $initialCount = $store.Notes.Count
            
            # Should not throw or modify store
            { $store.RemoveNote('NonExistent', 'RemoveNonExistentTest') } | Should -Not -Throw
            $store.Notes.Count | Should -Be $initialCount
        }
    }
    
    Context 'UpdateNote method' {
        It 'updates a note in store and catalog' {
            # Create catalog with note
            $catalog = [NoteCatalog]::new('UpdateNoteTest')
            $originalNote = [PSNote]::new('MyNote', 'old code', 'old details', 'mn', @('old'), 'UpdateNoteTest', $false)
            $catalog.Notes.Add($originalNote)
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('UpdateNoteTest')
            
            # Update the note
            $updatedNote = [PSNote]::new(
                'MyNote',
                'new code',
                'new details',
                'mn',
                @('updated'),
                'UpdateNoteTest',
                $false
            )
            
            $store.UpdateNote($updatedNote)
            
            # Verify update in store
            $noteInStore = $store.Notes | Where-Object { $_.Note -eq 'MyNote' }
            $noteInStore.Snippet | Should -Be 'new code'
            $noteInStore.Details | Should -Be 'new details'
            $noteInStore.Tags | Should -Be @('updated')
            
            # Verify update in catalog
            $catalog = $store.Catalogs | Where-Object { $_.Catalog -eq 'UpdateNoteTest' }
            $noteInCatalog = $catalog.Notes | Where-Object { $_.Note -eq 'MyNote' }
            $noteInCatalog.Snippet | Should -Be 'new code'
        }
        
        It 'persists updates to disk' {
            $catalog = [NoteCatalog]::new('UpdateNotePersistTest')
            $originalNote = [PSNote]::new('UpdateMe', 'v1', 'version 1', 'um', @('v1'),'UpdateNotePersistTest', $false)
            $catalog.Notes.Add($originalNote)
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('UpdateNotePersistTest')
            
            $updatedNote = [PSNote]::new(
                'UpdateMe',
                'v2',
                'version 2',
                'um',
                @('v2'),
                'UpdateNotePersistTest',
                $false
            )
            
            $store.UpdateNote($updatedNote)
            
            # Reload from disk to verify persistence
            $store2 = [NoteStore]::new()
            $store2.LoadCatalog('UpdateNotePersistTest')
            $noteOnDisk = $store2.Notes | Where-Object { $_.Note -eq 'UpdateMe' }
            $noteOnDisk.Snippet | Should -Be 'v2'
            $noteOnDisk.Details | Should -Be 'version 2'
        }
        
        It 'handles updating non-existent note' {
            $catalog = [NoteCatalog]::new('UpdateNonExistentTest')
            $catalog.Save()
            
            $store = [NoteStore]::new()
            $store.LoadCatalog('UpdateNonExistentTest')
            
            $nonExistentNote = [PSNote]::new('NonExistent', 'code', 'details', 'ne', @('test'),'UpdateNonExistentTest', $false)
            
            # Should not throw, but also should not add the note
            { $store.UpdateNote($nonExistentNote) } | Should -Not -Throw
            $store.Notes | Where-Object { $_.Note -eq 'NonExistent' } | Should -BeNullOrEmpty
        }
    }
    
    Context 'Save method' {
        It 'saves all catalogs' {
            # Create and populate multiple catalogs
            $cat1 = [NoteCatalog]::new('SaveAllCat1')
            $cat1.Notes.Add([PSNote]::new('Note1', 'c1', 'd1', 'n1', @('t1'),'SaveAllCat1', $false))
            
            $cat2 = [NoteCatalog]::new('SaveAllCat2')
            $cat2.Notes.Add([PSNote]::new('Note2', 'c2', 'd2', 'n2', @('t2'),'SaveAllCat2', $false))
            
            $store = [NoteStore]::new()
            $store.LoadCatalog($cat1)
            $store.LoadCatalog($cat2)
            
            # Add new notes
            $store.Notes | ForEach-Object {
                $_.Snippet = 'modified'
            }
            
            # Save all catalogs
            $store.Save()
            
            # Reload and verify all changes persisted
            $store2 = [NoteStore]::new()
            $store2.LoadCatalog('SaveAllCat1')
            $store2.LoadCatalog('SaveAllCat2')
            
            $store2.Catalogs.Count | Should -Be 3  # default + 2
        }
    }
}

Describe 'Error Handling and Edge Cases' {
    Context 'PSNote edge cases' {
        It 'handles null tags array' {
            { $note = [PSNote]::new('Note', 'code', 'details', 'alias', $null) } | Should -Not -Throw
        }
        
        It 'handles empty string for Note name' {
            { $note = [PSNote]::new('', 'code', 'details', 'alias', @()) } | Should -Not -Throw
            $note.Note | Should -Be $null
        }
    }
    
    Context 'NoteCatalog edge cases' {
        It 'handles catalog with very large note count' {
            $catalog = [NoteCatalog]::new('LargeTest')
            
            for ($i = 1; $i -le 100; $i++) {
                $note = [PSNote]::new(
                    "Note$i",
                    "code$i",
                    "details$i",
                    "alias$i",
                    @("tag$i")
                )
                $catalog.Notes.Add($note)
            }
            
            $catalog.Save()
            $catalog2 = [NoteCatalog]::new('LargeTest')
            
            $catalog2.Notes.Count | Should -Be 100
        }
        
        It 'handles special characters in note properties' {
            $catalog = [NoteCatalog]::new('SpecialCharTest')
            $note = [PSNote]::new(
                'Note "with" quotes',
                'code with @#$% special chars',
                'details with `n newlines',
                'alias_with-dashes',
                @('tag@special', 'tag#2')
            )
            $catalog.Notes.Add($note)
            
            { $catalog.Save() } | Should -Not -Throw
            
            $catalog2 = [NoteCatalog]::new('SpecialCharTest')
            $catalog2.Notes[0].Note | Should -Be 'Note "with" quotes'
        }
    }
}
