# Pester tests for Import-RemoteCatalog

Get-Module PSNotes | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest

    # Create a temporary directory for test files
    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\ImportRemoteCatalog"
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force

    # Set up test environment variable
    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir

    # Import the built module from bin
    $psd1 = Get-ChildItem -Path (Join-Path $Global:TopLevel 'bin') -Recurse -Filter 'PSNotes.psd1' |
        Select-Object -Last 1 -ExpandProperty FullName

    Import-Module $psd1 -Force

    # A "current-format" catalog JSON payload that NoteCatalog.Open should accept.
    # (Versioned object with Notes array)
    $script:MockRemoteCatalogJson = @(
        [pscustomobject]@{
            Catalog = 'RemotePayloadCatalog'
            Path    = 'Ignored.json'
            StoreVersion = 1
            Notes   = @(
                @{
                    Note    = 'remote-note-1'
                    Snippet = 'Get-Date'
                    Details = 'Remote note 1'
                    Alias   = 'r1'
                    Tags    = @('Remote','Test')
                    Catalog = 'RemotePayloadCatalog'
                },
                @{
                    Note    = 'remote-note-2'
                    Snippet = 'Get-Process | Select-Object -First 1'
                    Details = 'Remote note 2'
                    Alias   = 'r2'
                    Tags    = @('Remote','Test')
                    Catalog = 'RemotePayloadCatalog'
                }
            )
        }
    ) | ConvertTo-Json -Depth 10

    # Your real URLs (optional integration)
    $script:RealUrls = @(
        'https://gist.githubusercontent.com/mdowst/7198756f760ad0de0f635aaef5c4d338/raw/0676b9c41b27c40c0d8a28cd1e166838a2639828/RemotePSNote.json',
        'https://gist.githubusercontent.com/mdowst/a01faa8ed7bdb560e585420a5b97ae06/raw/a895c50ba700f20fb019e948c28fb5c3797432ff/PSNotes.Math.json'
    )
    # Load the class file
    . "$Global:TopLevel\src\Classes\NoteStore.class.ps1"
}

AfterAll {
    # Restore original environment
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
}

Describe "Import-RemoteCatalog" {

    BeforeEach {
        # Clean out store between tests
        Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue

        # Also clean nested folders (config/remote) if they exist
        if (Test-Path (Join-Path $env:PSNOTES_HOME 'config')) {
            Remove-Item (Join-Path $env:PSNOTES_HOME 'config') -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path (Join-Path $env:PSNOTES_HOME 'remote')) {
            Remove-Item (Join-Path $env:PSNOTES_HOME 'remote') -Recurse -Force -ErrorAction SilentlyContinue
        }

        Initialize-PSNoteStore
    }

    Context "Default behavior (register remote URL)" {

        It "registers the remote catalog and does not download immediately" {
            # If RegisterRemoteCatalog only registers, there should be no web call here.
            Mock Invoke-WebRequest { throw "Invoke-WebRequest should not be called for registration." }

            Import-RemoteCatalog -Name 'Tools' -Url 'https://example.invalid/Tools.json'

            InModuleScope PSNotes {
                $script:_noteStore | Should -Not -BeNullOrEmpty
                $script:_noteStore.Config | Should -Not -BeNullOrEmpty
                @($script:_noteStore.Config.RemoteCatalogs).Count | Should -Be 1

                $script:_noteStore.Config.RemoteCatalogs[0].Name | Should -Be 'Tools'
                $script:_noteStore.Config.RemoteCatalogs[0].Url  | Should -Be 'https://example.invalid/Tools.json'
            }

            Assert-MockCalled Invoke-WebRequest -Times 0 -Exactly
        }
    }

    Context "One-time import (creates local copy, no registration)" {

        It "downloads once and creates a local catalog file at ResolvePath(Name)" {
            Mock Invoke-WebRequest {
                [pscustomobject]@{
                    Content = $script:MockRemoteCatalogJson
                    Headers = @{}
                }
            } -ModuleName PSNotes

            Import-RemoteCatalog -Name 'OneTimeCatalog' -Url 'https://example.invalid/OneTime.json' -AsLocal

            # File should exist at ResolvePath(Name)
            $localPath = [NoteCatalog]::ResolvePath('OneTimeCatalog')
            Test-Path $localPath | Should -Be $true

            # Should not register in config
            InModuleScope PSNotes {
                @($script:_noteStore.Config.RemoteCatalogs).Count | Should -Be 0
            }

            # Notes should be available in the new catalog
            $notes = Get-PSNote -Catalog 'OneTimeCatalog'
            @($notes).Count | Should -BeGreaterThan 0
            $notes | ForEach-Object { $_.Catalog | Should -Be 'OneTimeCatalog' }

            Assert-MockCalled Invoke-WebRequest -Times 1 -Exactly -ModuleName PSNotes
        }

        It "throws when local catalog already exists and -Force is not provided" {
            Mock Invoke-WebRequest {
                [pscustomobject]@{
                    Content = $script:MockRemoteCatalogJson
                    Headers = @{}
                }
            } -ModuleName PSNotes

            # First import creates the file
            Import-RemoteCatalog -Name 'DupCatalog' -Url 'https://example.invalid/Dup.json' -AsLocal

            # Second import without -Force should throw
            { Import-RemoteCatalog -Name 'DupCatalog' -Url 'https://example.invalid/Dup.json' -AsLocal -ErrorAction Stop } |
                Should -Throw

            # Still should not register
            InModuleScope PSNotes {
                @($script:_noteStore.Config.RemoteCatalogs).Count | Should -Be 0
            }
        }

        It "overwrites when local catalog already exists and -Force is provided" {
            # First payload
            $payload1 = @(
                [pscustomobject]@{
                    Catalog = 'RemotePayloadCatalog'
                    Path    = 'Ignored.json'
                    StoreVersion = 1
                    Notes   = @(
                        @{
                            Note    = 'payload-1'
                            Snippet = 'Write-Output 1'
                            Details = 'First'
                            Alias   = 'p1'
                            Tags    = @('T')
                            Catalog = 'RemotePayloadCatalog'
                        }
                    )
                }
            ) | ConvertTo-Json -Depth 10

            # Second payload
            $payload2 = @(
                [pscustomobject]@{
                    Catalog = 'RemotePayloadCatalog'
                    Path    = 'Ignored.json'
                    StoreVersion = 1
                    Notes   = @(
                        @{
                            Note    = 'payload-2'
                            Snippet = 'Write-Output 2'
                            Details = 'Second'
                            Alias   = 'p2'
                            Tags    = @('T')
                            Catalog = 'RemotePayloadCatalog'
                        }
                    )
                }
            ) | ConvertTo-Json -Depth 10

            $script:call = 0
            Mock Invoke-WebRequest {
                $script:call++
                [pscustomobject]@{
                    Content = if ($script:call -eq 1) { $payload1 } else { $payload2 }
                    Headers = @{}
                }
            } -ModuleName PSNotes

            Import-RemoteCatalog -Name 'ForceCatalog' -Url 'https://example.invalid/Force.json' -AsLocal
            (Get-PSNote -Catalog 'ForceCatalog').Name | Should -Contain 'payload-1'

            Import-RemoteCatalog -Name 'ForceCatalog' -Url 'https://example.invalid/Force.json' -AsLocal -Force
            $notes = Get-PSNote -Catalog 'ForceCatalog'
            @($notes.Name) | Should -Contain 'payload-2'

            Assert-MockCalled Invoke-WebRequest -Times 2 -ModuleName PSNotes
        }
    }

    Context "Optional: Live URL integration" -Tag 'Integration' {

        It "can one-time import from a real URL (skips if unreachable)" {
            $url = $script:RealUrls[0]
            $name = 'LiveRemoteImport'

            try {
                Import-RemoteCatalog -Name $name -Url $url -AsLocal -Force -ErrorAction Stop
            }
            catch {
                Set-ItResult -Skipped -Because "Live URL unreachable or blocked: $($_.Exception.Message)"
                return
            }

            $localPath = [NoteCatalog]::ResolvePath($name)
            Test-Path $localPath | Should -Be $true

            $notes = Get-PSNote -Catalog $name
            @($notes).Count | Should -BeGreaterThan 0
        }
    }
}
