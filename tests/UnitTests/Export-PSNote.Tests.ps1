# Pester tests for Export-PSNote
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

    Import-Module (Join-Path $Global:TopLevel 'bin\PSNotes\0.9.9.9\PSNotes.psd1') -Force
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
    
    # Clean up test directory
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
}

Describe "Export-PSNote" {
    BeforeEach {
        # Define a fake note store for testing
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
        
        # Create an export directory for testing
        $script:ExportDir = Join-Path $script:TestDir 'Exports'
        $null = New-Item -Path $script:ExportDir -ItemType Directory -Force
    }
    
    Context "Exporting notes by object" {

        It "exports a single PSNote object to JSON file" {
            $note = Get-PSNote -Note 'az-login'
            $exportPath = Join-Path $script:ExportDir 'single.json'
            
            $note | Export-PSNote -Path $exportPath
            
            Test-Path $exportPath | Should -Be $true
            (Get-Content $exportPath | ConvertFrom-Json).Notes.Count | Should -BeGreaterThan 0
        }

        It "exports multiple PSNote objects to JSON file" {
            $notes = Get-PSNote -Note 'cred*'
            $exportPath = Join-Path $script:ExportDir 'multiple.json'
            
            $notes | Export-PSNote -Path $exportPath

            Test-Path $exportPath | Should -Be $true
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes.Count | Should -Be 2
        }

        It "exports all notes from a catalog using -Catalog parameter" {
            $exportPath = Join-Path $script:ExportDir 'catalog.json'
            
            Export-PSNote -Catalog 'Personal' -Path $exportPath
            
            Test-Path $exportPath | Should -Be $true
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Catalog | Should -Be 'Personal'
        }

        It "includes correct note properties in exported JSON" {
            $note = Get-PSNote -Note 'az-login'
            $exportPath = Join-Path $script:ExportDir 'properties.json'
            
            $note | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $exportedNote = $json.Notes[0]
            $exportedNote | Get-Member -MemberType NoteProperty | Should -Not -BeNullOrEmpty
            $exportedNote.Note | Should -Be 'az-login'
            $exportedNote.Snippet | Should -Be 'Connect-AzAccount'
        }

        It "excludes the Path property from exported JSON" {
            $note = Get-PSNote -Note 'az-login'
            $exportPath = Join-Path $script:ExportDir 'no-path.json'
            
            $note | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $exportedNote = $json.Notes[0]
            $exportedNote.PSObject.Properties.Name | Should -Not -Contain 'Path'
        }
    }

    Context "File handling" {

        It "throws an error when file already exists without -Force" {
            $exportPath = Join-Path $script:ExportDir 'existing.json'
            
            # Create initial file
            $note = Get-PSNote -Note 'az-login'
            $note | Export-PSNote -Path $exportPath
            
            # Attempt to overwrite without -Force
            { Get-PSNote -Note 'day-one' | Export-PSNote -Path $exportPath -ErrorAction Stop } | Should -Throw
        }

        It "overwrites existing file with -Force" {
            $exportPath = Join-Path $script:ExportDir 'force-overwrite.json'
            
            # Create initial file
            $note1 = Get-PSNote -Note 'az-login'
            $note1 | Export-PSNote -Path $exportPath
            
            # Overwrite with -Force
            $note2 = Get-PSNote -Note 'day-one'
            $note2 | Export-PSNote -Path $exportPath -Force
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Note | Should -Be 'day-one'
        }

        It "creates JSON file with UTF8 encoding without BOM" {
            $exportPath = Join-Path $script:ExportDir 'encoding.json'
            $note = Get-PSNote -Note 'az-login'
            
            $note | Export-PSNote -Path $exportPath
            
            $bytes = [System.IO.File]::ReadAllBytes($exportPath)
            # UTF8 without BOM should not start with EF BB BF
            ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) | Should -Be $false
        }
    }

    Context "Pipeline input" {

        It "accepts notes from Get-PSNote pipeline" {
            $exportPath = Join-Path $script:ExportDir 'pipeline.json'
            
            Get-PSNote -Note 'az-login' | Export-PSNote -Path $exportPath
            
            Test-Path $exportPath | Should -Be $true
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Note | Should -Be 'az-login'
        }

        It "handles multiple notes from pipeline" {
            $exportPath = Join-Path $script:ExportDir 'pipeline-multiple.json'
            
            Get-PSNote | Export-PSNote -Path $exportPath
            
            Test-Path $exportPath | Should -Be $true
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes.Count | Should -BeGreaterThan 1
        }

        It "handles filtered notes from Get-PSNote -Tag" {
            $exportPath = Join-Path $script:ExportDir 'filtered-tag.json'
            
            Get-PSNote -Tag 'Azure' | Export-PSNote -Path $exportPath
            
            Test-Path $exportPath | Should -Be $true
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Tags | Should -Contain 'Azure'
        }
    }

    Context "Catalog parameter set" {

        It "exports all notes from Personal catalog" {
            $exportPath = Join-Path $script:ExportDir 'personal-catalog.json'
            
            Export-PSNote -Catalog 'Personal' -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Catalog | Should -Be 'Personal'
            $json.Notes | Should -Not -BeNullOrEmpty
        }

        It "exports all notes from Work catalog" {
            $exportPath = Join-Path $script:ExportDir 'work-catalog.json'
            
            Export-PSNote -Catalog 'Work' -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Catalog | Should -Be 'Work'
        }

        It "sets catalog name to the exported catalog name" {
            $exportPath = Join-Path $script:ExportDir 'catalog-name.json'
            
            Export-PSNote -Catalog 'Personal' -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Catalog | Should -Be 'Personal'
        }
    }

    Context "Export object structure" {

        It "creates a valid NoteCatalog structure in JSON" {
            $exportPath = Join-Path $script:ExportDir 'structure.json'
            $note = Get-PSNote -Note 'az-login'
            
            $note | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Should -Contain 'StoreVersion'
            $json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Should -Contain 'Catalog'
            $json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Should -Contain 'Notes'
        }

        It "sets Catalog to 'Export' when exporting from Note parameter set" {
            $exportPath = Join-Path $script:ExportDir 'export-catalog.json'
            $note = Get-PSNote -Note 'az-login'
            
            $note | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Catalog | Should -Be 'Export'
        }
    }

    Context "Complex scenarios" {

        It "exports notes with special characters in Details" {
            New-PSNote -Note 'SpecialChars' -Snippet 'Test' -Details 'Text with "quotes" and special chars: @#$%' -Force
            $exportPath = Join-Path $script:ExportDir 'special-chars.json'
            
            Get-PSNote -Note 'SpecialChars' | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Details | Should -Match 'quotes'
        }

        It "exports notes with multiline Snippet" {
            $multilineSnippet = @'
Get-Process |
    Where-Object {$_.Memory -gt 100MB} |
    Select-Object -Property Name, Id, Memory
'@
            New-PSNote -Note 'Multiline' -Snippet $multilineSnippet -Force
            $exportPath = Join-Path $script:ExportDir 'multiline.json'
            
            Get-PSNote -Note 'Multiline' | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Snippet | Should -Match 'Get-Process'
        }

        It "exports notes with multiple tags" {
            New-PSNote -Note 'MultiTag' -Snippet 'Test' -Tags 'Tag1', 'Tag2', 'Tag3' -Force
            $exportPath = Join-Path $script:ExportDir 'multi-tag.json'
            
            Get-PSNote -Note 'MultiTag' | Export-PSNote -Path $exportPath
            
            $json = Get-Content $exportPath | ConvertFrom-Json
            $json.Notes[0].Tags.Count | Should -BeGreaterThan 2
        }

        It "exports notes and can be re-imported" {
            $exportPath = Join-Path $script:ExportDir 'reimport.json'
            $importDir = Join-Path $script:TestDir 'Import'
            $null = New-Item -Path $importDir -ItemType Directory -Force
            
            # Export notes
            Get-PSNote -Note 'az-login' | Export-PSNote -Path $exportPath
            
            # Import the exported file
            Import-PSNote -Path $exportPath -Catalog 'Imported' -DefaultBehavior 'OverwriteExistingNotes'
            
            # Verify the imported note exists
            $imported = Get-PSNote -Note 'az-login'
            $imported | Should -Not -BeNullOrEmpty
        }
    }
}
