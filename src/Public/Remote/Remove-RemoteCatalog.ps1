function Remove-RemoteCatalog {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [switch] $ConvertToLocal,

        [switch] $Force,

        [switch] $PassThru
    )

    $store = [NoteStore]::new()

    $action = if ($ConvertToLocal) {
        "Convert cached remote catalog to local and remove registration"
    }
    else {
        "Remove remote catalog registration"
    }

    if ($PSCmdlet.ShouldProcess($Url, $action)) {
        $removed = $store.RemoveRemoteCatalog($Url, [bool]$ConvertToLocal, [bool]$Force)
        if ($PassThru) { $removed }
    }
}