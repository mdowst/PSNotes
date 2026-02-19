# Pester tests for New-PSNote
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}
BeforeAll {
    Set-StrictMode -Version Latest
    
    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\NewPSNote"
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
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
}

Describe "New-PSNote" {
    BeforeEach {
        # Define a fake note store for testing
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
    }
    Context "Creating new notes" {

        It "creates a new note with Snippet parameter" {
            New-PSNote -Name 'TestSnippet' -Snippet 'Get-Process' -Details 'Test snippet' -Tags 'Test'
            
            $result = Get-PSNote -Name 'TestSnippet'
            $result.Name | Should -Be 'TestSnippet'
            $result.Snippet | Should -Be 'Get-Process'
            $result.Details | Should -Be 'Test snippet'
            $result.Tags | Should -Contain 'Test'
        }

        It "creates a new note with ScriptBlock parameter" {
            $scriptBlock = { Get-Service | Where-Object Status -eq 'Running' }
            New-PSNote -Name 'TestScriptBlock' -ScriptBlock $scriptBlock -Details 'Test scriptblock'
            
            $result = Get-PSNote -Name 'TestScriptBlock'
            $result.Name | Should -Be 'TestScriptBlock'
            $result.Snippet | Should -Be $scriptBlock.ToString()
            $result.Details | Should -Be 'Test scriptblock'
        }

        It "creates a new note with ScriptPath parameter" {
            $scriptFile = Join-Path $script:TestDir 'TestScriptPath.ps1'
            Set-Content -Path $scriptFile -Value 'Get-Date' -Force

            New-PSNote -Name 'TestScriptPath' -ScriptPath $scriptFile -Details 'Test script path'
            
            $result = Get-PSNote -Name 'TestScriptPath'
            $result.Name | Should -Be 'TestScriptPath'
            $result.Snippet | Should -Be $scriptFile
            $result.Kind | Should -Be 'Script'
            $result.Details | Should -Be 'Test script path'
        }

        It "creates a note with multiple tags" {
            New-PSNote -Name 'TestMultiTags' -Snippet 'Get-ChildItem' -Tags 'Files', 'Test', 'PowerShell'
            
            $result = Get-PSNote -Name 'TestMultiTags'
            $result.Tags | Should -Contain 'Files'
            $result.Tags | Should -Contain 'Test'
            $result.Tags | Should -Contain 'PowerShell'
        }

        It "creates a note with custom Alias" {
            New-PSNote -Name 'TestAlias' -Snippet 'Test-Connection' -Alias 'ping-test'
            
            $result = Get-PSNote -Name 'TestAlias'
            $result.Alias | Should -Be 'ping-test'
        }

        It "leave Alias blank when Alias is not specified" {
            New-PSNote -Name 'TestDefaultAlias' -Snippet 'Get-Date'
            
            $result = Get-PSNote -Name 'TestDefaultAlias'
            $result.Alias | Should -Be ''
        }

        It "creates a note with multiline snippet using here-string" {
            $multilineSnippet = @'
$stringBuilder = New-Object System.Text.StringBuilder
for ($i = 0; $i -lt 10; $i++){
    $stringBuilder.Append("Line $i`r`n") | Out-Null
}
$stringBuilder.ToString()
'@
            New-PSNote -Name 'TestMultiline' -Snippet $multilineSnippet -Details 'Multiline test'
            
            $result = Get-PSNote -Name 'TestMultiline'
            $result.Snippet | Should -Be $multilineSnippet
        }
    }

    Context "Run and Alias properties" {

        It "creates a note without an Alias and without Run" {
            New-PSNote -Name 'TestNoAliasNoRun' -Snippet 'Write-Output "Test snippet"' -Details 'Test snippet' -Tags 'Test' -Catalog 'TestCatalog'
            
            { TestNoAliasNoRun } | Should -Throw

            $result = Get-PSNote -Name 'TestNoAliasNoRun'
            $result.Run | Should -Be $false
            $result.Alias | Should -Be ''
            
            Get-PSNote -Name 'TestNoAliasNoRun' -Run | Should -Be "Test snippet"
        }

        It "creates a note with an Alias and without Run" {
            New-PSNote -Name 'TestAliasNoRun' -Snippet 'Write-Output "Test Alias and without Run"' -Details 'Test Alias and without Run' -Tags 'Test' -Catalog 'TestCatalog' -Alias 'testaliasnorun'
            
            testaliasnorun | Should -Be 'Write-Output "Test Alias and without Run"'
            testaliasnorun -run | Should -Be 'Test Alias and without Run'
            testaliasnorun -copy | Should -Be 'Write-Output "Test Alias and without Run"'
            
            $result = Get-PSNote -Name 'TestAliasNoRun'
            $result.Run | Should -Be $false
            $result.Alias | Should -Be 'testaliasnorun'

            Get-PSNote -Name 'TestAliasNoRun' -Run | Should -Be 'Test Alias and without Run'
        }

        It "creates a note with an Alias and with Run" {
            New-PSNote -Name 'TestRunAliasRun' -Snippet 'Write-Output "Test Alias and with Run"' -Details 'Test Alias and with Run' -Tags 'Test' -Catalog 'TestCatalog' -Alias 'testrunaliasrun' -Run $true
            
            testrunaliasrun | Should -Be 'Test Alias and with Run'
            testrunaliasrun -run | Should -Be 'Test Alias and with Run'
            testrunaliasrun -copy | Should -Be 'Write-Output "Test Alias and with Run"'
            
            $result = Get-PSNote -Name 'TestRunAliasRun'
            $result.Run | Should -Be $true
            $result.Alias | Should -Be 'testrunaliasrun'

            Get-PSNote -Name 'TestRunAliasRun' -Run | Should -Be 'Test Alias and with Run'
        }

        It "creates a note without an Alias and with Run" {
            New-PSNote -Name 'TestRunNoAliasRun' -Snippet 'Write-Output "Test no alias and with Run"' -Details 'Test no alias and with Run' -Tags 'Test' -Catalog 'TestCatalog' -Run $true
            
            { TestRunNoAliasRun } | Should -Throw

            Get-PSNote -Name 'TestRunNoAliasRun'
            $result = Get-PSNote -Name 'TestRunNoAliasRun'
            $result.Run | Should -Be $true
            $result.Alias | Should -Be ''

            Get-PSNote -Name 'TestRunNoAliasRun' -Run | Should -Be 'Test no alias and with Run'
        }
    }

    Context "Updating existing notes" {

        BeforeEach {
            # Create a note to update in each test
            New-PSNote -Name 'UpdateTest' -Snippet 'Get-Process' -Details 'Original' -Tags 'Test' -Force
        }

        It "throws an error when trying to overwrite without -Force" {
            New-PSNote -Name 'UpdateTest' -Snippet 'Get-Service' -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
            $err[0].Exception.Message | Should -Match "already exists"
        }

        It "updates an existing note with -Force" {
            New-PSNote -Name 'UpdateTest' -Snippet 'Get-Service' -Force
            
            $result = Get-PSNote -Name 'UpdateTest'
            $result.Snippet | Should -Be 'Get-Service'
        }

        It "updates only specified properties with -Force" {
            New-PSNote -Name 'UpdateTest' -Details 'Updated details' -Force
            
            $result = Get-PSNote -Name 'UpdateTest'
            $result.Details | Should -Be 'Updated details'
            $result.Snippet | Should -Be 'Get-Process'  # Original snippet should remain
        }

        It "updates Tags with -Force" {
            New-PSNote -Name 'UpdateTest' -Tags 'Updated', 'NewTag' -Force
            
            $result = Get-PSNote -Name 'UpdateTest'
            $result.Tags | Should -Contain 'Updated'
            $result.Tags | Should -Contain 'NewTag'
        }

        It "updates Alias with -Force" {
            New-PSNote -Name 'UpdateTest' -Alias 'new-alias' -Force
            
            $result = Get-PSNote -Name 'UpdateTest'
            $result.Alias | Should -Be 'new-alias'
        }

        It "updates existing note to ScriptPath with -Force" {
            $scriptFile = Join-Path $script:TestDir 'UpdateTestScript.ps1'
            Set-Content -Path $scriptFile -Value 'Get-Process' -Force

            New-PSNote -Name 'UpdateTest' -ScriptPath $scriptFile -Force

            $result = Get-PSNote -Name 'UpdateTest'
            $result.Snippet | Should -Be $scriptFile
            $result.Kind | Should -Be 'Script'
        }
    }

    Context "Alias validation" {

        It "accepts valid alias with letters, numbers, dashes, and underscores" {
            { New-PSNote -Name 'ValidAlias1' -Snippet 'Test' -Alias 'valid-alias_123' } | Should -Not -Throw
        }

        It "throws an error for alias with spaces" {
            { New-PSNote -Name 'InvalidAlias1' -Snippet 'Test' -Alias 'invalid alias' } | Should -Throw
        }

        It "throws an error for alias with special characters" {
            { New-PSNote -Name 'InvalidAlias2' -Snippet 'Test' -Alias 'invalid@alias' } | Should -Throw
        }

        It "throws an error for alias with dots" {
            { New-PSNote -Name 'InvalidAlias3' -Snippet 'Test' -Alias 'invalid.alias' } | Should -Throw
        }
    }

    Context "Parameter sets" {

        It "accepts Snippet parameter" {
            { New-PSNote -Name 'SnippetParam' -Snippet 'Get-Date' } | Should -Not -Throw
        }

        It "accepts ScriptBlock parameter" {
            { New-PSNote -Name 'ScriptBlockParam' -ScriptBlock { Get-Date } } | Should -Not -Throw
        }

        It "accepts ScriptPath parameter" {
            $scriptFile = Join-Path $script:TestDir 'ParamScriptPath.ps1'
            Set-Content -Path $scriptFile -Value 'Get-ChildItem' -Force
            { New-PSNote -Name 'ScriptPathParam' -ScriptPath $scriptFile } | Should -Not -Throw
        }

        It "converts ScriptBlock to string for storage" {
            $sb = { Get-Process | Select-Object -First 5 }
            New-PSNote -Name 'ScriptBlockConversion' -ScriptBlock $sb
            
            $result = Get-PSNote -Name 'ScriptBlockConversion'
            $result.Snippet | Should -Be $sb.ToString()
        }

        It "throws when ScriptPath does not exist" {
            $missingFile = Join-Path $script:TestDir 'MissingScript.ps1'
            { New-PSNote -Name 'MissingScriptPath' -ScriptPath $missingFile } | Should -Throw
        }
    }

    Context "Global alias creation" {

        It "creates a global alias for the note" {
            New-PSNote -Name 'AliasCreation' -Snippet 'Get-Date' -Alias 'test-global-alias'
            
            # Check if alias exists
            $aliasExists = Test-Path Alias:\test-global-alias
            $aliasExists | Should -Be $true
        }
    }
}
