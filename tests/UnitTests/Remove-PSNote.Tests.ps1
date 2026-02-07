# Pester tests for Remove-PSNote
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

Describe "Remove-PSNote" {
    BeforeEach {
        # Define a fake note store for testing
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
    }

    Context "Pipeline (ByObject parameter set)" {

        It "removes each piped note (calls NoteStore.RemoveNote)" {
            $toRemove = @(
                Get-PSnote -Note 'creds' -Catalog 'Work'
                Get-PSnote -Note 'az-login' -Catalog 'Personal'
            )

            $r = $toRemove | Remove-PSNote -Confirm:$false

            @($r).Count | Should -Be 2
            Get-PSnote -Note 'creds' -Catalog 'Work' | Should -Be $null
            Get-PSnote -Note 'az-login' -Catalog 'Personal' | Should -Be $null
        }

        It "honors -WhatIf (does not call RemoveNote)" {
            $toRemove = @(
                Get-PSnote -Note 'creds2' -Catalog 'Work'
            )

            $null = $toRemove | Remove-PSNote -WhatIf

            Get-PSnote -Note 'creds2' -Catalog 'Work' | Should -Not -Be $null
        }

        It "de-dupes piped notes by Catalog+Note" {
            $toRemove = @(
                Get-PSnote -Note 'creds2' -Catalog 'Work'
                Get-PSnote -Note 'creds2' -Catalog 'Work'
            )

            $r = $toRemove | Remove-PSNote -Confirm:$false

            @($r).Count | Should -Be 1
        }
    }

    Context "Discovery parameter sets (delegates to Get-PSNote)" {
        
        It "calls Get-PSNote with Note/Tag/Catalog when using Note parameter set" {
            $r = Remove-PSNote -Note 'cred*' -Tag 'AD' -Catalog 'Work' -Confirm:$false
            Write-Host $r.Note
            @($r).Count | Should -Be 1
            Get-PSnote -Note 'creds' -Catalog 'Work' | Should -Be $null
        }

        It "calls Get-PSNote with SearchString and Catalog when using Search parameter set" {
            $r = Remove-PSNote -SearchString 'Azure' -Catalog 'Personal' -Confirm:$false

            @($r).Count | Should -Be 1
            Get-PSnote -Note 'az-login' -Catalog 'Personal' | Should -Be $null
        }

        It "returns no output and does not call RemoveNote when Get-PSNote finds nothing" {
            Mock -CommandName Get-PSNote -MockWith { @() } -ModuleName PSNotes

            $r = Remove-PSNote -Note 'nope*' -Catalog 'Work' -Confirm:$false

            @($r).Count | Should -Be 0
        }
    }
}
