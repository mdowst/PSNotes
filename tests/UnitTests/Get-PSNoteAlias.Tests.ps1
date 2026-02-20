# Pester tests for Get-PSNote
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}
BeforeAll {
    Set-StrictMode -Version Latest
    
    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\GetPSNoteAlias"
    if(Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force
    
    # Set up test environment variable
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir

    $script:MockPath = Join-Path -Path $Global:TopLevel -ChildPath 'tests\UnitTests\Mocks'

    $psd1 = Get-ChildItem -Path (Join-Path $Global:TopLevel 'bin') -Recurse -Filter 'PSNotes.psd1' | Select-Object -Last 1 -ExpandProperty FullName
    Import-Module $psd1 -Force
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
}

Describe "Get-PSNoteAlias" {
    BeforeEach {
        # Define a fake note store for testing
        Get-ChildItem -Path $script:TestDir -Filter '*.json' | Remove-Item -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
    }
    
    Context "Default aliases" {

        It "default to run" {
            day | Should -Be 'day'
        }

        It "default to copy" {
            c2 | Should -Contain 'Write-Output creds2'
        }
    }
    
    Context "Copy switch" {
        BeforeEach {
            Mock Set-Clipboard -ModuleName PSNotes
        }

        It "default to run with -Copy" {
            day -Copy | Should -Be 'Write-Output day'
            Should -Invoke Set-Clipboard -ParameterFilter { $Value -eq 'Write-Output day' } -Times 1 -ModuleName PSNotes
        }

        It "default to copy with -Copy" {
            c2 -Copy | Should -Contain 'Write-Output creds2'
            Should -Invoke Set-Clipboard -ParameterFilter { $Value -eq 'Write-Output creds2' } -Times 1 -ModuleName PSNotes
        }
    }

    Context "Run switch" {

        It "default to run with -Run" {
            day -Run | Should -Be 'day'
        }

        It "default to copy with -Copy" {
            c2 -Run | Should -Contain 'creds2'
        }
    }

    Context "Script execution and clipboard copying" {

        It "executes the note by default" {
            $scriptFile = Join-Path $script:TestDir 'TestScriptPath.ps1'
            Set-Content -Path $scriptFile -Value '"Hello Pester"' -Force

            New-PSNote -Name 'TestScriptPath' -ScriptPath $scriptFile -Details 'Test script path' -Catalog 'TestScriptStore' -Alias 'TestScriptPath'

            TestScriptPath | Should -Be 'Hello Pester'
        }

        It "executes a script note when the script path contains spaces" {
            $scriptDirWithSpaces = Join-Path $script:TestDir 'Folder With Spaces'
            $null = New-Item -Path $scriptDirWithSpaces -ItemType Directory -Force
            $scriptFile = Join-Path $scriptDirWithSpaces 'Test Script Path.ps1'
            Set-Content -Path $scriptFile -Value '"Hello Space Path"' -Force

            New-PSNote -Name 'TestScriptPathWithSpaces' -ScriptPath $scriptFile -Details 'Test script path with spaces' -Catalog 'TestScriptStore' -Alias 'TestScriptPathWithSpaces'

            TestScriptPathWithSpaces | Should -Be 'Hello Space Path'
        }

        It "copies to clipboard without executing when -Copy is used" {
            $scriptFile = Join-Path $script:TestDir 'TestScriptPath.ps1'
            Set-Content -Path $scriptFile -Value '"Hello Pester"' -Force

            New-PSNote -Name 'TestScriptPath' -ScriptPath $scriptFile -Details 'Test script path' -Catalog 'TestScriptStore' -Alias 'TestScriptPath'

            TestScriptPath -Copy | Should -Be $scriptFile
        }

        It "copies to clipboard without executing when -Copy is used" {
            $scriptFile = Join-Path $script:TestDir 'TestScriptPath.ps1'
            Set-Content -Path $scriptFile -Value '"Hello Pester"' -Force

            New-PSNote -Name 'TestScriptPath' -ScriptPath $scriptFile -Details 'Test script path' -Catalog 'TestScriptStore' -Alias 'TestScriptPath'

            TestScriptPath -Copy | Should -Be $scriptFile
        }
    }

    Context "Error handling" {

        It "returns an error when called directly" {
            { Get-PSNoteAlias -ErrorAction Stop } | Should -Throw "The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly."
        }

        It "returns an error when alias does not exist" {
            { NonExistentAlias } | Should -Throw
        }
    }
}