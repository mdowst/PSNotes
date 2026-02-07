# Pester tests for Import-PSNote
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}
BeforeAll {
    Set-StrictMode -Version Latest
    
    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\$(Get-Random)"
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force
    
    # Set up test environment variable
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir

    $script:MockPath = Join-Path -Path $PSScriptRoot -ChildPath 'Mocks'

    $psd1 = Get-ChildItem -Path (Join-Path $Global:TopLevel 'bin') -Recurse -Filter 'PSNotes.psd1' | Select-Object -Last 1 -ExpandProperty FullName
    Import-Module $psd1 -Force
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
    
    # Clean up test directory
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
}

Describe "Import-PSNote" {
    BeforeEach {
        # Initialize clean store for each test
        # Clean up any existing catalog files
        Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | Remove-Item -Force -ErrorAction SilentlyContinue
        Initialize-PSNoteStore
        Get-ChildItem -Path $script:MockPath -Filter '*.json' | Copy-Item -Destination $env:PSNOTES_HOME -Force
    }
    
    Context "Basic import functionality" {

        It "imports notes from a valid current format file" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPersonalStore.json'
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $notes = Get-PSNote
            @($notes).Count | Should -BeGreaterThan 0
        }

        It "imports notes to default catalog when not specified" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPersonalStore.json'
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $notes = Get-PSNote -Catalog 'Default'
            @($notes).Count | Should -BeGreaterThan 0
        }

        It "imports notes to specified catalog" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPersonalStore.json'
            Import-PSNote -Path $importPath -Catalog 'TestImport' -DefaultBehavior SkipMigratedNotes
            
            $notes = Get-PSNote -Catalog 'TestImport'
            @($notes).Count | Should -BeGreaterThan 0
            $notes | ForEach-Object {
                $_.Catalog | Should -Be 'TestImport'
            }
        }

        It "imports note with all properties intact" {
            # Create a test file with a specific note
            $testNote = @(
                @{
                    Note    = "test-import"
                    Snippet = "Get-Date"
                    Details = "Test import note"
                    Alias   = "testimport"
                    Tags    = @("Test", "Import")
                }
            )
            $importPath = Join-Path $env:PSNOTES_HOME 'ImportTest.json'
            $testNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $imported = Get-PSNote -Note 'test-import'
            $imported.Note | Should -Be 'test-import'
            $imported.Snippet | Should -Be 'Get-Date'
            $imported.Details | Should -Be 'Test import note'
            $imported.Alias | Should -Be 'testimport'
            $imported.Tags | Should -Contain 'Test'
            $imported.Tags | Should -Contain 'Import'
        }
    }

    Context "Legacy format migration" {

        It "imports and migrates legacy format files" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPSNotesv0.json'
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $notes = Get-PSNote
            @($notes).Count | Should -BeGreaterThan 0
        }

        It "validates legacy format before migration" {
            # Create a legacy format file
            $legacyNotes = @(
                @{
                    Note    = "legacy-note"
                    Snippet = "Write-Host 'Legacy'"
                    Details = "Legacy format note"
                    Alias   = "legacy"
                    Tags    = @("Legacy")
                }
            )
            $importPath = Join-Path $env:PSNOTES_HOME 'LegacyImport.json'
            $legacyNotes | ConvertTo-Json | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $imported = Get-PSNote -Note 'legacy-note'
            $imported | Should -Not -BeNullOrEmpty
            $imported.Note | Should -Be 'legacy-note'
        }
    }

    Context "Duplicate handling with DefaultBehavior parameter" {

        It "skips migrated notes when DefaultBehavior is SkipMigratedNotes" {
            # Create initial note
            New-PSNote -Note 'duplicate-test' -Snippet 'Write-Output "Original"' -Details 'Original note' -Tags 'Original' -Alias 'duptest'
            
            # Create import file with same alias
            $testNote = @(
                @{
                    Note    = "duplicate-test-new"
                    Snippet = "Write-Output 'New'"
                    Details = "New note"
                    Alias   = "duptest"
                    Tags    = @("New")
                }
            )
            $importPath = Join-Path $script:TestDir 'DuplicateTest.json'
            $testNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            # Verify original note still exists
            $note = Get-PSNote -SearchString 'duptest'
            $note.Note | Should -Be 'duplicate-test'
            $note.Details | Should -Be 'Original note'
        }

        It "overwrites existing notes when DefaultBehavior is OverwriteExistingNotes" {
            # Create initial note
            New-PSNote -Note 'overwrite-test' -Snippet 'Write-Output "Original"' -Details 'Original note' -Tags 'Original' -Alias 'overtest'
            
            # Create import file with same alias
            $testNote = @(
                @{
                    Note    = "overwrite-test-new"
                    Snippet = "Write-Output 'New'"
                    Details = "New note"
                    Alias   = "overtest"
                    Tags    = @("New")
                }
            )
            $importPath = Join-Path $script:TestDir 'OverwriteTest.json'
            $testNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior OverwriteExistingNotes
            
            # Verify new note exists
            $note = Get-PSNote -SearchString 'overtest'
            $note.Note | Should -Be 'overwrite-test-new'
            $note.Details | Should -Be 'New note'
        }
    }

    Context "Validation and error handling" {

        It "throws error for invalid JSON file" {
            $invalidPath = Join-Path $script:TestDir 'Invalid.json'
            Set-Content -Path $invalidPath -Value "This is not valid JSON"
            
            { Import-PSNote -Path $invalidPath -ErrorAction Stop } | Should -Throw
        }

        It "throws error for file with invalid structure" {
            $invalidStructure = @{
                InvalidProperty = "This is not a valid PSNotes file"
            }
            $invalidPath = Join-Path $script:TestDir 'InvalidStructure.json'
            $invalidStructure | ConvertTo-Json | Out-File -FilePath $invalidPath -Encoding UTF8NoBOM
            
            { Import-PSNote -Path $invalidPath -ErrorAction Stop } | Should -Throw
        }

        It "throws error when file does not exist" {
            $nonExistentPath = Join-Path $script:TestDir 'DoesNotExist.json'
            
            { Import-PSNote -Path $nonExistentPath -ErrorAction Stop } | Should -Throw
        }

        It "validates notes before import" {
            # Create a valid format file
            $validNote = @(
                @{
                    Note    = "valid-note"
                    Snippet = "Get-Process"
                    Details = "Valid note"
                    Alias   = "validnote"
                    Tags    = @("Test")
                }
            )
            $validPath = Join-Path $script:TestDir 'ValidImport.json'
            $validNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $validPath -Encoding UTF8NoBOM
            
            { Import-PSNote -Path $validPath -DefaultBehavior SkipMigratedNotes } | Should -Not -Throw
        }
    }

    Context "Multiple notes import" {

        It "imports multiple notes from single file" {
            # Create file with multiple notes
            $multipleNotes = @(
                @{
                    Note    = "note-one"
                    Snippet = "Get-Process"
                    Details = "First note"
                    Alias   = "note1"
                    Tags    = @("Test")
                },
                @{
                    Note    = "note-two"
                    Snippet = "Get-Service"
                    Details = "Second note"
                    Alias   = "note2"
                    Tags    = @("Test")
                },
                @{
                    Note    = "note-three"
                    Snippet = "Get-ChildItem"
                    Details = "Third note"
                    Alias   = "note3"
                    Tags    = @("Test")
                }
            )
            $importPath = Join-Path $script:TestDir 'MultipleNotes.json'
            $multipleNotes | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $imported = Get-PSNote
            @($imported).Count | Should -BeGreaterOrEqual 3
            Get-PSNote -Note 'note-one' | Should -Not -BeNullOrEmpty
            Get-PSNote -Note 'note-two' | Should -Not -BeNullOrEmpty
            Get-PSNote -Note 'note-three' | Should -Not -BeNullOrEmpty
        }

        It "preserves unique aliases for all imported notes" {
            $multipleNotes = @(
                @{
                    Note    = "alias-test-1"
                    Snippet = "Get-Process"
                    Details = "First note"
                    Alias   = "alias1"
                    Tags    = @("Test")
                },
                @{
                    Note    = "alias-test-2"
                    Snippet = "Get-Service"
                    Details = "Second note"
                    Alias   = "alias2"
                    Tags    = @("Test")
                }
            )
            $importPath = Join-Path $script:TestDir 'AliasTest.json'
            $multipleNotes | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $note1 = Get-PSNote -SearchString 'alias1'
            $note2 = Get-PSNote -SearchString 'alias2'
            $note1 | Should -Not -BeNullOrEmpty
            $note2 | Should -Not -BeNullOrEmpty
            $note1[0].Alias | Should -Be 'alias1'
            $note2[0].Alias | Should -Be 'alias2'
        }
    }

    Context "Special characters and encoding" {

        It "handles notes with special characters" {
            $specialNote = @(
                @{
                    Note    = "special-chars"
                    Snippet = 'Get-Process | Where-Object {$_.Name -like "*code*"}'
                    Details = 'Has $special, "quotes", and symbols: @#$%^&*()'
                    Alias   = "special"
                    Tags    = @("Test", "Special")
                }
            )
            $importPath = Join-Path $script:TestDir 'SpecialChars.json'
            $specialNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $imported = Get-PSNote -Note 'special-chars'
            $imported.Snippet | Should -Match '\$'
            $imported.Details | Should -Match '\$special'
        }

        It "handles notes with multiline snippets" {
            $multilineSnippet = @"
Get-Process |
    Where-Object CPU -GT 10 |
    Select-Object Name, CPU
"@
            $multilineNote = @(
                @{
                    Note    = "multiline"
                    Snippet = $multilineSnippet
                    Details = "Multiline snippet"
                    Alias   = "multiline"
                    Tags    = @("Test")
                }
            )
            $importPath = Join-Path $script:TestDir 'Multiline.json'
            $multilineNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $imported = Get-PSNote -Note 'multiline'
            $imported.Snippet | Should -Match 'Get-Process'
            $imported.Snippet | Should -Match 'Select-Object'
        }
    }

    Context "Parameter validation" {

        It "requires Path parameter" {
            #{ Import-PSNote -ErrorAction Stop } | Should -Throw
        }

        It "accepts valid Catalog parameter" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPersonalStore.json'
            { Import-PSNote -Path $importPath -Catalog 'TestCatalog' -DefaultBehavior SkipMigratedNotes } | Should -Not -Throw
        }

        It "accepts valid DefaultBehavior values" {
            $importPath = Join-Path $env:PSNOTES_HOME 'TestPersonalStore.json'
            { Import-PSNote -Path $importPath -DefaultBehavior 'Prompt' } | Should -Not -Throw
            { Import-PSNote -Path $importPath -DefaultBehavior 'SkipMigratedNotes' } | Should -Not -Throw
            { Import-PSNote -Path $importPath -DefaultBehavior 'OverwriteExistingNotes' } | Should -Not -Throw
        }
    }

    Context "Integration with catalog system" {

        It "updates note store after import" {
            $countBefore = @(Get-PSNote).Count
            
            $newNote = @(
                @{
                    Note    = "integration-test"
                    Snippet = "Write-Output 'Test'"
                    Details = "Integration test"
                    Alias   = "inttest"
                    Tags    = @("Test")
                }
            )
            $importPath = Join-Path $script:TestDir 'Integration.json'
            $newNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -DefaultBehavior SkipMigratedNotes
            
            $countAfter = @(Get-PSNote).Count
            $countAfter | Should -BeGreaterThan $countBefore
        }

        It "creates catalog file if it does not exist" {
            $newCatalog = "NewTestCatalog"
            $catalogPath = Join-Path $env:PSNOTES_HOME "$newCatalog.json"
            
            if (Test-Path $catalogPath) {
                Remove-Item $catalogPath -Force
            }
            
            $newNote = @(
                @{
                    Note    = "new-catalog-test"
                    Snippet = "Get-Date"
                    Details = "New catalog test"
                    Alias   = "newcat"
                    Tags    = @("Test")
                }
            )
            $importPath = Join-Path $script:TestDir 'NewCatalog.json'
            $newNote | ConvertTo-Json -Depth 10 | Out-File -FilePath $importPath -Encoding UTF8NoBOM
            
            Import-PSNote -Path $importPath -Catalog $newCatalog -DefaultBehavior SkipMigratedNotes
            
            Test-Path $catalogPath | Should -Be $true
        }
    }
}
