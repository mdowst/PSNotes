# Pester tests for Get-PSNote
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

Describe "Get-PSNote" {
    BeforeEach {
        # Define a fake note store for testing
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
    }
    
    Context "Note parameter set" {

        It "returns all notes when called with no parameters" {
            $r = Get-PSNote
            @($r).Count | Should -Be 4
        }

        It "filters notes by -Note wildcard" {
            $r = Get-PSNote -Note 'cred*'
            @($r).Count | Should -Be 2
            $r.Note | Should -Contain 'creds'
            $r.Note | Should -Contain 'creds2'
        }

        It "filters notes by -Tag (exact match)" {
            $r = Get-PSNote -Tag 'Azure'
            @($r).Count | Should -Be 1
            $r[0].Note | Should -Be 'az-login'
        }

        It "filters notes by -Note and -Tag together" {
            $r = Get-PSNote -Note '*cred*' -Tag 'AD'
            @($r).Count | Should -Be 1
            $r[0].Note | Should -Be 'creds'
        }

        It "copies the first returned snippet to clipboard when -Copy is used" {
            Mock -CommandName Set-Clipboard -MockWith { param($Value) } -Verifiable -ModuleName PSNotes
            Mock -CommandName Get-Command -MockWith { [pscustomobject]@{ Name = 'Set-Clipboard' } } -ModuleName PSNotes
            Mock -CommandName Read-Host -MockWith { param($Prompt) 1 } -ModuleName PSNotes

            Get-PSNote -Note 'cred*' -Copy | Out-Null

            Assert-MockCalled -CommandName Set-Clipboard -Times 1 -Exactly -ModuleName PSNotes -ParameterFilter {
                $Value -eq 'Get-Credential'
            }
        }

        It "invokes Invoke-PSNote with the first note when -Run is used" {
            Mock -CommandName Invoke-PSNote -MockWith { param($Note) } -Verifiable -ModuleName PSNotes
            Mock -CommandName Read-Host -MockWith { param($Prompt) 1 } -ModuleName PSNotes

            Get-PSNote -Note 'cred*' -Run | Out-Null

            Assert-MockCalled -CommandName Invoke-PSNote -Times 1 -Exactly -ModuleName PSNotes -ParameterFilter {
                $Note.Note -eq 'creds'
            }
        }
    }
    
    Context "Search parameter set" {

        It "returns notes where SearchString matches Note/Alias/Details/Snippet" {
            $r = Get-PSNote -SearchString 'Azure'
            @($r).Count | Should -BeGreaterThan 0
            $r.Note | Should -Contain 'az-login'
        }

        It "returns notes where SearchString matches Tags (even if other fields don't match)" {
            $r = Get-PSNote -SearchString 'Journal'
            @($r).Count | Should -Be 1
            $r[0].Note | Should -Be 'day-one'
        }
    }

}