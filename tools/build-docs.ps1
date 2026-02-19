$currentPath = (Get-Location).Path
$sourceRoot = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $sourceRoot

function Add-ExamplePowerShellFence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $lines = Get-Content -LiteralPath $Path
    $updated = [System.Collections.Generic.List[string]]::new()

    $pendingExample = $false
    $inInsertedFence = $false
    $removingAlias = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if($removingAlias) {
            if ($line -match '^##') {
                $removingAlias = $false
            }
            else {
                continue
            }
        }
        
        if ($line -match '^## ALIASES\b') {
            $removingAlias = $true
            continue
        }
        elseif ($line -match '^\{\{ ') {
            continue
        }
        elseif ($line -match '^### EXAMPLE\b') {
            $updated.Add($line)
            $pendingExample = $true
            continue
        }

        if ($pendingExample) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                $updated.Add($line)
                continue
            }

            if ($line -eq '```powershell') {
                $updated.Add($line)
                $pendingExample = $false
                $inInsertedFence = $true
                continue
            }

            $updated.Add('```powershell')
            $updated.Add($line)
            $pendingExample = $false
            $inInsertedFence = $true
            continue
        }

        if ($inInsertedFence -and [string]::IsNullOrWhiteSpace($line)) {
            if ($updated.Count -eq 0 -or $updated[$updated.Count - 1] -ne '```') {
                $updated.Add('```')
            }
            $updated.Add($line)
            $inInsertedFence = $false
            continue
        }

        if ($inInsertedFence -and $line -eq '```') {
            $updated.Add($line)
            $inInsertedFence = $false
            continue
        }

        $updated.Add($line)
    }

    if ($inInsertedFence -and ($updated.Count -eq 0 -or $updated[$updated.Count - 1] -ne '```')) {
        $updated.Add('```')
    }

    Set-Content -LiteralPath $Path -Value $updated
}

if (-not (Test-Path .\bin\PSNotes\)) {
    throw "Project must be built first"
}

$psd1 = Get-ChildItem .\bin -Filter 'PSNotes.psd1' -Recurse | Select-Object -Last 1 
Import-Module $psd1.FullName -Force

Get-ChildItem .\Documentation\PSNotes -Filter '*.md' | Remove-Item -Force

$newMarkdownCommandHelpSplat = @{
    ModuleInfo     = Get-Module PSNotes
    OutputFolder   = '.\Documentation'
    HelpVersion    = '1.0.0.0'
    WithModulePage = $true
}
New-MarkdownCommandHelp @newMarkdownCommandHelpSplat

Get-ChildItem .\Documentation\PSNotes -Filter '*.md' | ForEach-Object {
    Add-ExamplePowerShellFence -Path $_.FullName
}


$readme = Get-Content .\README.md
$docs = Get-ChildItem .\Documentation -Filter '*.md' | ForEach-Object {
    $content = Get-Content -LiteralPath $_.FullName
    "| [$($_.BaseName)](Documentation/$($_.Name)) | $($content[$content.IndexOf('## SYNOPSIS')+2]) |"
}

$commands = $false
$readmeupdate = foreach ($line in $readme) {
    if ($line -eq '# Commands') {
        $commands = $true
        $line
        ''
        '| Cmdlet | Synopsis |'
        '| ------ | -------- |'
        $docs
        ''
        '[top](#psnotes)'
    }
    elseif ($commands -and $line -match '^#') {
        $commands = $false
    }

    if (-not $commands) {
        $line
    }
}

#$readmeupdate | Out-File .\README.md

Set-Location -LiteralPath $currentPath
#>