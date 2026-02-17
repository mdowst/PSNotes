Get-Module PSNotes | Remove-Module -Force -ErrorAction SilentlyContinue

$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest

    $script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\RemoveRemoteCatalog"
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
                        Tags    = @('Remote', 'Test')
                        Catalog = $CatalogName
                        Run     = $false
                        Kind    = 'Snippet'
                    }
                )
            }
        ) | ConvertTo-Json -Depth 10
    }

    function Set-CacheForRemoteEntry {
        param(
            [Parameter(Mandatory)][RemoteCatalogSource] $Entry,
            [Parameter(Mandatory)][string] $CatalogName
        )

        # Some implementations store CacheFile relative to PSNOTES_HOME; others may store absolute.
        $cacheRelOrAbs = [string]$Entry.CacheFile
        $cacheRelOrAbs | Should -Not -BeNullOrEmpty

        $cachePath = if ([System.IO.Path]::IsPathRooted($cacheRelOrAbs)) {
            $cacheRelOrAbs
        }
        else {
            Join-Path $env:PSNOTES_HOME $cacheRelOrAbs
        }

        $cacheDir = Split-Path $cachePath -Parent
        if (-not (Test-Path $cacheDir)) { $null = New-Item -Path $cacheDir -ItemType Directory -Force }

        (New-MockCatalogJson -CatalogName $CatalogName) | Set-Content -Path $cachePath -Encoding UTF8
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

    Context "Remove-RemoteCatalog (unregister)" {

        It "removes a registered remote by pipeline object" {
            $url = 'https://example.invalid/tools.json'
            Import-RemoteCatalog -Name 'Tools' -Url $url

            $remotes = @(Get-RemoteCatalog)
            $remotes.Count | Should -Be 1

            $target = $remotes | Where-Object Url -eq $url | Select-Object -First 1
            $target | Should -Not -BeNullOrEmpty

            $target | Remove-RemoteCatalog -Confirm:$false

            @(Get-RemoteCatalog).Count | Should -Be 0
        }

        It "throws when attempting to remove an unregistered remote object" {
            InModuleScope PSNotes {
                $fake = [RemoteCatalogSource]::new()
                $fake.Name = 'Fake'
                $fake.Url = 'https://example.invalid/not-registered.json'
                $fake.CacheFile = 'remote\does-not-matter.json'
                { $fake | Remove-RemoteCatalog -Confirm:$false -ErrorAction Stop } | Should -Throw
            }
        }
    }

    Context "Remove-RemoteCatalog -ConvertToLocal" {

        It "throws if no cached copy exists for the registered remote" {
            $url = 'https://example.invalid/tools.json'
            Import-RemoteCatalog -Name 'Tools' -Url $url

            $entry = (Get-RemoteCatalog | Where-Object Url -eq $url | Select-Object -First 1)
            $entry | Should -Not -BeNullOrEmpty

            { $entry | Remove-RemoteCatalog -ConvertToLocal -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It "converts cached remote catalog to a local catalog file and unregisters the remote" {
            InModuleScope PSNotes {
                $url = 'https://example.invalid/tools.json'
                $name = 'Tools'

                Import-RemoteCatalog -Name $name -Url $url

                $entry = (Get-RemoteCatalog | Where-Object Url -eq $url | Select-Object -First 1)
                $entry | Should -Not -BeNullOrEmpty

                # Create cached catalog JSON at the configured cache path
                $MockCatalogJson = @(
                    [pscustomobject]@{
                        Catalog      = $name
                        Path         = 'Ignored.json'
                        StoreVersion = 1
                        Notes        = @(
                            @{
                                Note    = 'remote-note-1'
                                Snippet = 'Get-Date'
                                Details = 'Remote note 1'
                                Alias   = 'r1'
                                Tags    = @('Remote', 'Test')
                                Catalog = $name
                                Run     = $false
                                Kind    = 'Snippet'
                            }
                        )
                    }
                ) | ConvertTo-Json -Depth 10
                # Some implementations store CacheFile relative to PSNOTES_HOME; others may store absolute.
                $cacheRelOrAbs = [string]$Entry.CacheFile
                $cacheRelOrAbs | Should -Not -BeNullOrEmpty

                $cachePath = if ([System.IO.Path]::IsPathRooted($cacheRelOrAbs)) {
                    $cacheRelOrAbs
                }
                else {
                    Join-Path $env:PSNOTES_HOME $cacheRelOrAbs
                }

                $cacheDir = Split-Path $cachePath -Parent
                if (-not (Test-Path $cacheDir)) { $null = New-Item -Path $cacheDir -ItemType Directory -Force }

                $MockCatalogJson | Set-Content -Path $cachePath -Encoding UTF8

                $entry | Remove-RemoteCatalog -ConvertToLocal -Confirm:$false

                # Remote unregistered
                @(Get-RemoteCatalog).Count | Should -Be 0

                # Local file created
                $localPath = [NoteCatalog]::ResolvePath($name)
                Test-Path $localPath | Should -Be $true

                # Notes load under that local catalog
                $notes = @(Get-PSNote -Catalog $name)
                $notes.Count | Should -BeGreaterThan 0
                $notes[0].Catalog | Should -Be $name
            }
        }

        It "does not overwrite an existing local catalog unless -Force is provided" {
            InModuleScope PSNotes {
                $url = 'https://example.invalid/tools.json'
                $name = 'Tools'

                Import-RemoteCatalog -Name $name -Url $url

                $entry = (Get-RemoteCatalog | Where-Object Url -eq $url | Select-Object -First 1)
                $entry | Should -Not -BeNullOrEmpty

                # Pre-create local catalog
            
                $localPath = [NoteCatalog]::ResolvePath($name)
                $MockCatalogJson = @(
                    [pscustomobject]@{
                        Catalog      = $name
                        Path         = 'Ignored.json'
                        StoreVersion = 1
                        Notes        = @(
                            @{
                                Note    = 'remote-note-1'
                                Snippet = 'Get-Date'
                                Details = 'Remote note 1'
                                Alias   = 'r1'
                                Tags    = @('Remote', 'Test')
                                Catalog = $name
                                Run     = $false
                                Kind    = 'Snippet'
                            }
                        )
                    }
                ) | ConvertTo-Json -Depth 10
                $MockCatalogJson | Set-Content -Path $localPath -Encoding UTF8

                # Also create cached remote copy (required for convert)
                # Some implementations store CacheFile relative to PSNOTES_HOME; others may store absolute.
                $cacheRelOrAbs = [string]$Entry.CacheFile
                $cacheRelOrAbs | Should -Not -BeNullOrEmpty

                $cachePath = if ([System.IO.Path]::IsPathRooted($cacheRelOrAbs)) {
                    $cacheRelOrAbs
                }
                else {
                    Join-Path $env:PSNOTES_HOME $cacheRelOrAbs
                }

                $cacheDir = Split-Path $cachePath -Parent
                if (-not (Test-Path $cacheDir)) { $null = New-Item -Path $cacheDir -ItemType Directory -Force }

                $MockCatalogJson | Set-Content -Path $cachePath -Encoding UTF8

                { $entry | Remove-RemoteCatalog -ConvertToLocal -Confirm:$false -ErrorAction Stop } | Should -Throw

                # With -Force it should succeed
                $entry | Remove-RemoteCatalog -ConvertToLocal -Force -Confirm:$false

                @(Get-RemoteCatalog).Count | Should -Be 0
                Test-Path $localPath | Should -Be $true
            }
        }
    }
}
