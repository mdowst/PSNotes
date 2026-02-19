Get-Module PSNotes | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest

    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\RemoteCatalog"
    if (Test-Path $script:TestDir) {
        Remove-Item -Path $script:TestDir -Recurse -Force
    }
    $null = New-Item -Path $script:TestDir -ItemType Directory -Force

    $script:OriginalPSNotesHome = $env:PSNOTES_HOME
    $env:PSNOTES_HOME = $script:TestDir

    $psd1 = Get-ChildItem -Path (Join-Path $Global:TopLevel 'bin') -Recurse -Filter 'PSNotes.psd1' |
        Select-Object -Last 1 -ExpandProperty FullName

    Import-Module $psd1 -Force

    function New-MockCatalogJson {
        param(
            [Parameter(Mandatory)][string] $CatalogName
        )

        @(
            [pscustomobject]@{
                Catalog      = $CatalogName
                Path         = 'Ignored.json'
                StoreVersion = 1
                Notes        = @(
                    @{
                        Note    = 'remote-note-1'
                        Snippet = 'Get-Date'
                        Details = 'Remote note 1'
                        Alias   = 'r1'
                        Tags    = @('Remote','Test')
                        Catalog = $CatalogName
                        Run     = $false
                        Kind    = 'Snippet'
                    }
                )
            }
        ) | ConvertTo-Json -Depth 10
    }
}

AfterAll {
    $env:PSNOTES_HOME = $script:OriginalPSNotesHome
}

Describe "Remote Catalog Commands" {

    BeforeEach {
        # Clean store between tests
        Get-ChildItem -Path $env:PSNOTES_HOME -Recurse -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

        Initialize-PSNoteStore
    }

    Context "Get-RemoteCatalog" {

        It "returns an empty array when no remotes are registered" {
            $remotes = @(Get-RemoteCatalog)
            $remotes.Count | Should -Be 0
        }

        It "returns registered remotes" {
            Import-RemoteCatalog -Name 'Tools' -Url 'https://example.invalid/tools.json'
            Import-RemoteCatalog -Name 'Math'  -Url 'https://example.invalid/math.json'

            $remotes = @(Get-RemoteCatalog)
            $remotes.Count | Should -Be 2

            # Don’t over-assume shape — just verify url/name are present if your object has them
            # If your RemoteCatalogSource uses different property names, adjust these assertions.
            @($remotes.Url)  | Should -Contain 'https://example.invalid/tools.json'
            @($remotes.Url)  | Should -Contain 'https://example.invalid/math.json'
            @($remotes.Name) | Should -Contain 'Tools'
            @($remotes.Name) | Should -Contain 'Math'
        }
    }
}
