# Pester tests for Set-PSNote
Get-Module PSNotes | Remove-Module -Force
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}
BeforeAll {
    Set-StrictMode -Version Latest
    
    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\SetPSNote"
    if(Test-Path $script:TestDir) {
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

Describe "Set-PSNote" {
    BeforeEach {
        # Define a fake note store for testing
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestPersonalStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Personal.json') -Force
        Copy-Item -Path (Join-Path -Path $script:MockPath -ChildPath 'TestWorkStore.json') -Destination (Join-Path -Path $env:PSNOTES_HOME -ChildPath 'Work.json') -Force

        Initialize-PSNoteStore
    }

    Context "Updating existing notes" {

        BeforeEach {
            # Create a note to update
            New-PSNote -Note 'SetTestNote' -Snippet 'Get-Process' -Details 'Original details' -Tags 'Test' -Catalog 'Personal'
        }

        It "updates Snippet of an existing note" {
            Set-PSNote -Note 'SetTestNote' -Snippet 'Get-Service' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Snippet | Should -Be 'Get-Service'
        }

        It "updates Details of an existing note" {
            Set-PSNote -Note 'SetTestNote' -Details 'Updated details' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Details | Should -Be 'Updated details'
            $result.Snippet | Should -Be 'Get-Process'  # Original snippet should remain
        }

        It "updates Tags of an existing note" {
            Set-PSNote -Note 'SetTestNote' -Tags 'Updated', 'NewTag' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Tags | Should -Contain 'Updated'
            $result.Tags | Should -Contain 'NewTag'
        }

        It "updates Alias of an existing note" {
            Set-PSNote -Note 'SetTestNote' -Alias 'new-alias' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Alias | Should -Be 'new-alias'
        }

        It "updates with ScriptBlock parameter" {
            $scriptBlock = { Get-ChildItem | Measure-Object }
            Set-PSNote -Note 'SetTestNote' -ScriptBlock $scriptBlock -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Snippet | Should -Be $scriptBlock.ToString()
        }

        It "updates with ScriptPath parameter" {
            $scriptFile = Join-Path $script:TestDir 'SetTestScriptPath.ps1'
            Set-Content -Path $scriptFile -Value 'Get-Date' -Force

            Set-PSNote -Note 'SetTestNote' -ScriptPath $scriptFile -Catalog 'Personal'

            $result = Get-PSNote -Note 'SetTestNote'
            $result.Snippet | Should -Be $scriptFile
            $result.Kind | Should -Be 'Script'
        }

        It "updates multiple properties at once" {
            Set-PSNote -Note 'SetTestNote' -Snippet 'Get-Date' -Details 'New details' -Tags 'Updated','Time' -Alias 'date-alias' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'SetTestNote'
            $result.Snippet | Should -Be 'Get-Date'
            $result.Details | Should -Be 'New details'
            $result.Tags | Should -Contain 'Updated'
            $result.Tags | Should -Contain 'Time'
            $result.Alias | Should -Be 'date-alias'
        }
    }

    Context "Creating notes when they don't exist" {

        It "creates a new note with warning when note doesn't exist" {
            Set-PSNote -Note 'NonExistentNote' -Snippet 'Get-Date' -Details 'New note' -Catalog 'Personal' -WarningVariable warn -WarningAction SilentlyContinue
            
            $result = Get-PSNote -Note 'NonExistentNote'
            $result.Name | Should -Be 'NonExistentNote'
            $result.Snippet | Should -Be 'Get-Date'
            $warn.Count | Should -BeGreaterThan 0
        }

        It "creates a new note with blank alias when creating non-existent note" {
            Set-PSNote -Note 'CreatedNoteBlank' -Snippet 'Test' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'CreatedNoteBlank'
            $result.Alias | Should -Be ''
        }

        It "creates a new note with alias when creating non-existent note" {
            Set-PSNote -Note 'CreatedNoteAlias' -Snippet 'Test' -Catalog 'Personal' -Alias 'CreatedNoteAlias'
            
            $result = Get-PSNote -Note 'CreatedNoteAlias'
            $result.Alias | Should -Be 'CreatedNoteAlias'
        }

        It "creates a new note with custom alias when creating non-existent note" {
            Set-PSNote -Note 'CreatedWithAlias' -Snippet 'Test' -Alias 'custom-alias' -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'CreatedWithAlias'
            $result.Alias | Should -Be 'custom-alias'
        }

        It "creates a new note from ScriptPath when note doesn't exist" {
            $scriptFile = Join-Path $script:TestDir 'CreateScriptPath.ps1'
            Set-Content -Path $scriptFile -Value 'Get-Process' -Force

            Set-PSNote -Note 'CreatedFromScriptPath' -ScriptPath $scriptFile -Catalog 'Personal'

            $result = Get-PSNote -Note 'CreatedFromScriptPath'
            $result.Snippet | Should -Be $scriptFile
            $result.Kind | Should -Be 'Script'
        }
    }

    Context "Pipeline input" {
        It "accepts Note from pipeline by property name" {
            New-PSNote -Note 'PipelineTestNote' -Snippet 'Get-Process' -Catalog 'Personal' -Force
            $noteObject = [PSCustomObject]@{
                Note    = 'PipelineTestNote'
                Snippet = 'Get-Service'
                Catalog = 'Personal'
            }
            
            $noteObject | Set-PSNote
            
            $result = Get-PSNote -Note 'PipelineTestNote'
            $result.Snippet | Should -Be 'Get-Service'
        }

        It "accepts Catalog from pipeline by property name" {
            New-PSNote -Note 'PipelineTestNote' -Snippet 'Get-Process' -Catalog 'Personal' -Force
            $noteObject = [PSCustomObject]@{
                Note    = 'PipelineTestNote'
                Snippet = 'Get-Content'
                Catalog = 'Personal'
            }
            
            $noteObject | Set-PSNote
            
            $result = Get-PSNote -Note 'PipelineTestNote'
            $result.Snippet | Should -Be 'Get-Content'
        }

        It "accepts ScriptPath from pipeline by property name" {
            New-PSNote -Note 'PipelineScriptPathNote' -Snippet 'Get-Date' -Catalog 'Personal' -Force
            $scriptFile = Join-Path $script:TestDir 'PipelineScriptPath.ps1'
            Set-Content -Path $scriptFile -Value 'Get-ChildItem' -Force

            $noteObject = [PSCustomObject]@{
                Note       = 'PipelineScriptPathNote'
                ScriptPath = $scriptFile
                Catalog    = 'Personal'
            }

            $noteObject | Set-PSNote

            $result = Get-PSNote -Note 'PipelineScriptPathNote'
            $result.Snippet | Should -Be $scriptFile
            $result.Kind | Should -Be 'Script'
        }
    }

    Context "Alias validation" {

        It "accepts valid alias with letters, numbers, dashes, and underscores" {
            { Set-PSNote -Note 'ValidAliasSet' -Alias 'valid-alias_123' -Snippet 'Test' -Catalog 'Personal' } | Should -Not -Throw
        }

        It "throws an error for alias with spaces" {
            { Set-PSNote -Note 'InvalidAliasSet1' -Alias 'invalid alias' -Snippet 'Test' -Catalog 'Personal' } | Should -Throw
        }

        It "throws an error for alias with special characters" {
            { Set-PSNote -Note 'InvalidAliasSet2' -Alias 'invalid@alias' -Snippet 'Test' -Catalog 'Personal' } | Should -Throw
        }
    }

    Context "Parameter sets" {

        It "accepts Snippet parameter" {
            { Set-PSNote -Note 'SnippetParamSet' -Snippet 'Get-Date' -Catalog 'Personal' } | Should -Not -Throw
        }

        It "accepts ScriptBlock parameter" {
            { Set-PSNote -Note 'ScriptBlockParamSet' -ScriptBlock { Get-Date } -Catalog 'Personal' } | Should -Not -Throw
        }

        It "accepts ScriptPath parameter" {
            $scriptFile = Join-Path $script:TestDir 'ScriptPathParamSet.ps1'
            Set-Content -Path $scriptFile -Value 'Get-ChildItem' -Force
            { Set-PSNote -Note 'ScriptPathParamSet' -ScriptPath $scriptFile -Catalog 'Personal' } | Should -Not -Throw
        }

        It "converts ScriptBlock to string for storage" {
            $sb = { Get-Process | Select-Object -First 5 }
            Set-PSNote -Note 'ScriptBlockConversionSet' -ScriptBlock $sb -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'ScriptBlockConversionSet'
            $result.Snippet | Should -Be $sb.ToString()
        }

        It "throws when ScriptPath does not exist" {
            $missingFile = Join-Path $script:TestDir 'MissingScriptPath.ps1'
            { Set-PSNote -Note 'MissingScriptPath' -ScriptPath $missingFile -Catalog 'Personal' } | Should -Throw
        }
    }

    Context "Multiline snippets" {

        It "updates a note with multiline snippet using here-string" {
            $multilineSnippet = @'
$array = @()
for ($i = 0; $i -lt 10; $i++){
    $array += $i
}
$array
'@
            Set-PSNote -Note 'MultilineSetTest' -Snippet $multilineSnippet -Catalog 'Personal'
            
            $result = Get-PSNote -Note 'MultilineSetTest'
            $result.Snippet | Should -Be $multilineSnippet
        }
    }

    Context "Global alias creation" {

        It "creates or updates a global alias for the note" {
            Set-PSNote -Note 'AliasSetCreation' -Snippet 'Get-Date' -Alias 'test-set-alias' -Catalog 'Personal'
            
            # Check if alias exists
            $aliasExists = Test-Path Alias:\test-set-alias
            $aliasExists | Should -Be $true
        }
    }
}
