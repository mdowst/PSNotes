function Update-PSNoteSetting {
    <#
    .SYNOPSIS
    Guided settings editor for NoteConfigStore.

    .DESCRIPTION
    Presents a simple Read-Host driven menu that lets the user update values on a
    NoteConfigStore instance (Main, ExitOnCopy, ForegroundColor, BackgroundColor),
    then optionally save changes back to disk.

    .PARAMETER Config
    Optional existing NoteConfigStore instance. If not provided, a new one is created.

    .PARAMETER NoSave
    Do not persist changes automatically. (Still allows user to choose Save in the menu.)

    .OUTPUTS
    NoteConfigStore (the updated instance)
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter()]
        [NoteConfigStore] $Config,

        [switch] $NoSave
    )

    if (-not $Config) {
        $Config = [NoteConfigStore]::new()
    }

    function Write-SettingsHeader {
        param([NoteConfigStore] $Cfg)

        Clear-Host
        Write-Host "PSNotes Settings" -ForegroundColor Yellow
        Write-Host ("=" * 60)
        Write-Host ("  1) Default Screen (Main)      : {0}" -f $Cfg.Main)
        Write-Host ("  2) Exit On Copy               : {0}" -f $Cfg.ExitOnCopy)
        Write-Host ("  3) Foreground Color           : {0}" -f $Cfg.ForegroundColor)
        Write-Host ("  4) Background Color           : {0}" -f $Cfg.BackgroundColor)
        Write-Host ""
        Write-Host "  S) Save"
        Write-Host "  R) Reset to defaults"
        Write-Host "  Q) Quit"
        Write-Host ""
    }

    function Read-Choice {
        param([string]$Prompt)
        return (Read-Host $Prompt).Trim()
    }

    function Select-EnumValue {
        param(
            [Parameter(Mandatory)] [Type] $EnumType,
            [Parameter(Mandatory)] [string] $Title,
            [Parameter(Mandatory)] [string] $CurrentValue
        )

        $values = [Enum]::GetNames($EnumType)

        while ($true) {
            Clear-Host
            Write-Host $Title -ForegroundColor Yellow
            Write-Host ("Current: {0}" -f $CurrentValue)
            Write-Host ("-" * 60)

            for ($i = 0; $i -lt $values.Count; $i++) {
                Write-Host ("  {0,2}) {1}" -f ($i + 1), $values[$i])
            }

            Write-Host ""
            Write-Host "  B) Back"
            Write-Host ""

            $sel = (Read-Host "Select number (or B)").Trim()

            if ($sel -match '^(B|b)$') { return $null }

            $n = 0
            if ([int]::TryParse($sel, [ref]$n)) {
                if ($n -ge 1 -and $n -le $values.Count) {
                    return $values[$n - 1]
                }
            }
        }
    }

    function Select-ConsoleColor {
        param(
            [string] $Title,
            [ConsoleColor] $Current
        )
        $picked = Select-EnumValue -EnumType ([ConsoleColor]) -Title $Title -CurrentValue $Current.ToString()
        if ($null -eq $picked) { return $null }

        $try = [ConsoleColor]::Black
        if ([Enum]::TryParse([string]$picked, [ref]$try)) {
            return $try
        }
        return $null
    }

    function Select-PSNoteMenuItem {
        param(
            [string] $Title,
            [PSNoteMenuItem] $Current
        )
        $picked = Select-EnumValue -EnumType ([PSNoteMenuItem]) -Title $Title -CurrentValue $Current.ToString()
        if ($null -eq $picked) { return $null }

        $try = [PSNoteMenuItem]::Welcome
        if ([Enum]::TryParse([string]$picked, [ref]$try)) {
            return $try
        }
        return $null
    }

    function Read-Bool {
        param(
            [string] $Title,
            [bool] $Current
        )

        while ($true) {
            Clear-Host
            Write-Host $Title -ForegroundColor Yellow
            Write-Host ("Current: {0}" -f $Current)
            Write-Host ""
            Write-Host "  Y) True"
            Write-Host "  N) False"
            Write-Host "  B) Back"
            Write-Host ""

            $sel = (Read-Host "Choose (Y/N/B)").Trim()

            switch -Regex ($sel) {
                '^(B|b)$' { return $null }
                '^(Y|y)$' { return $true }
                '^(N|n)$' { return $false }
            }
        }
    }

    $dirty = $false
    $run = $true
    while ($run) {
        Write-SettingsHeader -Cfg $Config

        if ($dirty) {
            Write-Host "Unsaved changes." -ForegroundColor Yellow
            Write-Host ""
        }

        $choice = Read-Choice -Prompt "Select option"

        switch -Regex ($choice) {
            '^(1)$' {
                $new = Select-PSNoteMenuItem -Title "Default Screen (Main)" -Current $Config.Main
                if ($null -ne $new -and $new -ne $Config.Main) {
                    $Config.Main = $new
                    $dirty = $true
                }
            }
            '^(2)$' {
                $new = Read-Bool -Title "Exit On Copy" -Current $Config.ExitOnCopy
                if ($null -ne $new -and $new -ne $Config.ExitOnCopy) {
                    $Config.ExitOnCopy = [bool]$new
                    $dirty = $true
                }
            }
            '^(3)$' {
                $new = Select-ConsoleColor -Title "Foreground Color" -Current $Config.ForegroundColor
                if ($null -ne $new -and $new -ne $Config.ForegroundColor) {
                    $Config.ForegroundColor = $new
                    $dirty = $true
                }
            }
            '^(4)$' {
                $new = Select-ConsoleColor -Title "Background Color" -Current $Config.BackgroundColor
                if ($null -ne $new -and $new -ne $Config.BackgroundColor) {
                    $Config.BackgroundColor = $new
                    $dirty = $true
                }
            }
            '^(S|s)$' {
                if (-not $NoSave) {
                    $Config.Save()
                    $dirty = $false
                    Write-Host "`nSaved to: $($Config.Path)" -ForegroundColor Green
                }
                else {
                    $Config.Save()
                    $dirty = $false
                    Write-Host "`nSaved to: $($Config.Path)" -ForegroundColor Green
                }
                Start-Sleep -Milliseconds 650
            }
            '^(R|r)$' {
                $confirm = Read-Choice -Prompt "Reset to defaults? (Y/N)"
                if ($confirm -match '^(Y|y)$') {
                    $Config.SetDefaults()
                    $dirty = $true
                }
            }
            '^(Q|q)$' {
                if ($dirty) {
                    $confirm = Read-Choice -Prompt "You have unsaved changes. Save before quitting? (Y/N)"
                    if ($confirm -match '^(Y|y)$') {
                        $Config.Save()
                        $dirty = $false
                    }
                }
                $run = $false
            }
            default {
                # If user typed something like "welcome" for Main, accept it as a convenience
                if (-not [string]::IsNullOrWhiteSpace($choice)) {
                    $tryMain = [PSNoteMenuItem]::Welcome
                    if ([Enum]::TryParse($choice, [ref]$tryMain)) {
                        if ($tryMain -ne $Config.Main) {
                            $Config.Main = $tryMain
                            $dirty = $true
                        }
                    }
                }
            }
        }
    }

    return $Config
}
