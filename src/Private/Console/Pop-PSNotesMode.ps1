function Pop-PSNotesMode {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$State)

    if ($State.ReturnMode.Count -ge 2) {
        $State.Mode = $State.ReturnMode[-2]
        $State.ReturnMode = $State.ReturnMode[0..($State.ReturnMode.Count - 2)]
    }
    else {
        $State.Mode = $State.Settings.Main
        $State.ReturnMode = @()
    }
}
