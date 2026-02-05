# Pester tests for Update-PSNoteStore duplicate handling
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest

    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\UpdatePSNoteStore"
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force

    # Set up test environment variable
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir

    Import-Module (Join-Path $Global:TopLevel 'bin\PSNotes\0.2.0.1\PSNotes.psd1') -Force
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome

    # Clean up test directory
    if (Test-Path $script:TestDir) {
        #Remove-Item -Path $script:TestDir -Recurse -Force
    }
}

Describe 'Update-PSNoteStore duplicate handling' {
    BeforeEach {
        if (Test-Path $env:PSNOTES_HOME) {
            Remove-Item -Path $env:PSNOTES_HOME -Recurse -Force
        }
        $null = New-Item -Path $env:PSNOTES_HOME -ItemType Directory -Force

        # Existing catalog with duplicate alias
        $existing = [pscustomobject]@{
            StoreVersion = 1
            Catalog      = 'ExistingDup'
            Notes        = @(
                [pscustomobject]@{
                    Note    = 'MigrateDup01'
                    Snippet = 'blah'
                    Details = ''
                    Alias   = 'dup1'
                    Tags    = $null
                    Run     = $false
                    Kind    = 0
                },
                [pscustomobject]@{
                    Note    = 'Unique01'
                    Snippet = 'blah'
                    Details = ''
                    Alias   = 'notadupadup'
                    Tags    = $null
                    Run     = $false
                    Kind    = 0
                }
            )
        }
        $existing | ConvertTo-Json -Depth 6 | Out-File (Join-Path $env:PSNOTES_HOME 'ExistingDup.json') -Encoding utf8

        # Old format catalog (array) with duplicate and unique aliases
        $legacy = @(
            [pscustomobject]@{
                Note    = 'MigrateDup01'
                Alias   = 'dup1'
                Details = 'dup'
                Tags    = @()
                Snippet = 'test'
            },
            [pscustomobject]@{
                Note    = 'MigrateDup02'
                Alias   = 'dup2'
                Details = 'dup'
                Tags    = @()
                Snippet = 'test'
            }
        )
        $legacy | ConvertTo-Json -Depth 6 | Out-File (Join-Path $env:PSNOTES_HOME 'PSNotes.json') -Encoding utf8

        Initialize-PSNoteStore
    }

    It 'SkipMigratedNotes keeps existing duplicate and removes migrated duplicate' {
        Update-PSNoteStore -DefaultBehavior SkipMigratedNotes | Out-Null

        $migrated = Get-Content (Join-Path $env:PSNOTES_HOME 'PSNotes.json') -Raw | ConvertFrom-Json
        $migrated.Notes.Alias | Should -Contain 'dup2'
        $migrated.Notes.Alias | Should -Not -Contain 'dup1'

        $existingAfter = Get-Content (Join-Path $env:PSNOTES_HOME 'ExistingDup.json') -Raw | ConvertFrom-Json
        $existingAfter.Notes.Alias | Should -Contain 'dup1'
    }

    It 'OverwriteExistingNotes keeps migrated duplicate and removes existing duplicate' {
        Update-PSNoteStore -DefaultBehavior OverwriteExistingNotes | Out-Null

        $migrated = Get-Content (Join-Path $env:PSNOTES_HOME 'PSNotes.json') -Raw | ConvertFrom-Json
        $migrated.Notes.Alias | Should -Contain 'dup1'
        $migrated.Notes.Alias | Should -Contain 'dup2'

        $existingAfter = Get-Content (Join-Path $env:PSNOTES_HOME 'ExistingDup.json') -Raw | ConvertFrom-Json
        $existingAfter.Notes.Alias | Should -Not -Contain 'dup1'
    }
}
