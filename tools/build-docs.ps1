$currentPath = (Get-Location).Path
$sourceRoot = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $sourceRoot

if(-not (Test-Path .\bin\PSNotes\)) {
    throw "Project must be built first"
}

$psd1 = Get-ChildItem .\bin -Filter 'PSNotes.psd1' -Recurse | Select-Object -Last 1 
Import-Module $psd1.FullName -Force

Get-ChildItem .\Documentation -Filter '*.md' | Remove-Item -Force


$newMarkdownCommandHelpSplat = @{
    ModuleInfo = Get-Module PSNotes
    OutputFolder = '.\Documentation'
    HelpVersion = '1.0.0.0'
    WithModulePage = $true
}
New-MarkdownCommandHelp @newMarkdownCommandHelpSplat


$readme = Get-Content .\README.md
$docs = Get-ChildItem .\Documentation -Filter '*.md' | ForEach-Object{
    $content = Get-Content -LiteralPath $_.FullName
    "| [$($_.BaseName)](Documentation/$($_.Name)) | $($content[$content.IndexOf('## SYNOPSIS')+2]) |"
}

$commands = $false
$readmeupdate = foreach($line in $readme){
    if($line -eq '# Commands'){
        $commands = $true
        $line
        ''
        '| Cmdlet | Synopsis |'
        '| ------ | -------- |'
        $docs
        ''
        '[top](#psnotes)'
    }
    elseif($commands -and $line -match '^#'){
        $commands = $false
    }

    if(-not $commands){
        $line
    }
}

#$readmeupdate | Out-File .\README.md

Set-Location -LiteralPath $currentPath
#>