#requires -Module EZOut
param(
    $formatPath = (Join-Path $PSScriptRoot 'src/PSNotes.format.ps1xml')
)
# Regenerates PSNotes.format.ps1xml using EZOut.

$views = @(
    Write-FormatView -TypeName 'PSNote' -Name 'PSNote' -Action {
        "$('-' * 40)`n`n" +
        "Note    : $($_.Note)`n" +
        "Details : $($_.Details)`n" +
        "Alias   : $($_.Alias)`n" +
        "Snippet :`n`n" +
        "$($_.Snippet)`n`n"
    }

    Write-FormatView -TypeName 'SplatBlock' -Name 'SplatBlock' -Action {
        if ($_.SetBlock) {
            "ParameterSet : $($_.ParameterSet)`n" +
            "IsDefault    : $($_.IsDefault)`n" +
            "SetBlock     :" +
            "$($_.SetBlock.Split("`n") | ForEach-Object { "`n           $($_.Trim())" })" +
            "`nHashBlock  :" +
            "$($_.HashBlock.Split("`n") | ForEach-Object { "`n           $($_)" })"
        }
        elseif ($_.ParameterSet) {
            "ParameterSet : $($_.ParameterSet)`n" +
            "IsDefault    : $($_.IsDefault)`n" +
            "Parameters   : $($_.HashBlock)`n"
        }
        else {
            "$($_.HashBlock)"
        }
    }

    Write-FormatView -TypeName 'PSNoteSearch' -Name 'PSNoteSearch' -Property Note, Details, Alias, Tags, Snippet -Width 25, 15, 15, 15, 0

    Write-FormatView -TypeName 'PSNote' -Name 'PSNote' -Property Note, Details, Alias, Tags, Snippet -Width 25, 15, 15, 15, 0

    Write-FormatView -TypeName 'PSNote' -Name 'PSNote' -Property Note, Details, Alias, Tags, Snippet -AsList
)

$views |
    Out-FormatData -ModuleName 'PSNotes' |
    Set-Content -Path $formatPath -Encoding UTF8

# Emit the file path so build scripts can consume it easily.
$formatPath
