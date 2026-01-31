$Path = Join-Path (Split-Path $PSScriptRoot) 'src'

$psd1 = Join-Path -Path $Path -ChildPath 'PSNotes.psd1'
$psm1 = Join-Path -Path $Path -ChildPath 'PSNotes.psm1'

$psm1Script = {
    $Path = $PSScriptRoot
    # Import the functions
    foreach ($folder in @('classes', 'private', 'public')) {
        $root = Join-Path -Path $Path -ChildPath $folder
        if (Test-Path -Path $root) {
            Write-Verbose "processing folder $root"
            $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

            # dot source each file
            $files | where-Object { $_.name -NotLike '*.Tests.ps1' } |
            ForEach-Object { Write-Verbose $_.name; . $_.FullName }
        }
    }

    # Load all commands to noteObjects
    Initialize-PSNotes
}

$psm1Script.ToString() | Out-File -FilePath $psm1 -Encoding UTF8 -Force
Import-Module -Name $psd1 -Force -Verbose
Remove-Item -Path $psm1 -Force