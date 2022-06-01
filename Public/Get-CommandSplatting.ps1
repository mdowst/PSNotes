Function Get-CommandSplatting {
    <#
    .SYNOPSIS
    Use to output the parameters for a command in splatting format

    .DESCRIPTION
    Use to output the parameters for a command in splatting format

    .PARAMETER Command
    The command to get the parameters for

    .PARAMETER ParameterSet
    Use to specify a specific parameter set. Use the -ListParameterSets to get a quick
    view of all the different Parameter Set names. 

    .PARAMETER ListParameterSets
    Use to list the different Parameter Sets available for the command. Output is shortened 
    to only show the names. Use -All to return splatting for all parameter sets.

    .PARAMETER All
    Use to return full splatting for all parameter sets

    .PARAMETER IncludeCommon
    Use to include the PowerShell common parameters in the splatting output. (e.g. Verbose, ErrorAction, etc.)

    .EXAMPLE
    Get the default parameter set for Get-Item
    PS:\> Get-CommandSplatting -Command 'Get-Item'

    Name      : Path
    IsDefault : True
    SetBlock :
            [string[]]$Path = ''
            [string]$Filter = ''
            [string[]]$Include = ''
            [string[]]$Exclude = ''
            [Boolean]$Force = $false # Switch
            [pscredential]$Credential = ''
            [string[]]$Stream = ''
    HashBlock :
            $Item = @{
                    Path       = $Path       #Required
                    Filter     = $Filter
                    Include    = $Include
                    Exclude    = $Exclude
                    Force      = $Force
                    Credential = $Credential
                    Stream     = $Stream
            }
            Get-Item @Item

    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'ParameterSet')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]    
        [string]$Command,
        [Parameter(ParameterSetName = 'ParameterSet', Position = 1)]
        [string]$ParameterSet,
        [Parameter(ParameterSetName = 'ListParameterSets', Position = 1)]
        [switch]$ListParameterSets,
        [Parameter(ParameterSetName = 'All', Position = 1)]
        [switch]$All,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]$IncludeCommon,
        [Parameter(Mandatory = $false, Position = 3)]
        [switch]$Copy
    )

    # Get the command
    $commandData = Get-Command $command

    # Get the parameter sets
    $ParameterSets = $null
    if ($All -eq $true) {
        $ParameterSets = @($commandData.ParameterSets)
        if ($ParameterSets.Count -eq 0) {
            throw "Unable to find parameter sets"
        }
    }
    elseif ($ListParameterSets -eq $true) {
        $Output = $commandData.ParameterSets | Select-Object -Property @{l = 'ParameterSet'; e = { $_.Name } }, IsDefault, @{l = 'Parameters'; e = { @($_.Parameters.Name | 
                    Where-Object { $_ -notin [System.Management.Automation.Cmdlet]::CommonParameters }) -join (', ') }
        } |
        ForEach-Object { 
            [SplatBlock]@{
                ParameterSet = $_.ParameterSet
                IsDefault    = $_.IsDefault
                HashBlock    = $_.Parameters
                SetBlock     = $null
            } 
        }
    }
    elseif (-not [string]::IsNullOrEmpty($ParameterSet)) {
        $ParameterSets = $commandData.ParameterSets | Where-Object { $_.Name -eq $ParameterSet }
        if ($ParameterSets.Count -lt 1 -and $Output.Count -eq 0) {
            throw "Unable to find parameter set '$($ParameterSet)'"
        }
    }
    else {
        $ParameterSets = @($commandData.ParameterSets | Where-Object { $_.IsDefault -eq $trufe })
        if ($ParameterSets.Count -eq 0) {
            $ParameterSets = @($commandData.ParameterSets[0])
        }
        if ($ParameterSets.Count -lt 1) {
            throw "Unable to find the default parameter set"
        }
    }

    $hash = $command.Split('-')[-1]

    if ($ListParameterSets -ne $true) {
        $Output = foreach ($set in $ParameterSets) {
            [System.Collections.Generic.List[PSObject]]$hashBlock = @()
            [System.Collections.Generic.List[PSObject]]$setBlock = @()
            $hashBlock.Add("`$$($hash)$($set.Name) = @{")
            $length = 0

            $Parameters = $set.Parameters
            if ($IncludeCommon -ne $true) {
                $Parameters = $set.Parameters | Where-Object { $_.Name -notin 
                    [System.Management.Automation.Cmdlet]::CommonParameters }
            }
            $Parameters.Name | ForEach-Object { if ($_.Length -gt $length) { $length = $_.length } }

            $LastOrder = $Parameters | Sort-Object Position | Select-Object -ExpandProperty Position -Last 1
            if ($LastOrder -ge 0) {
                $SortedParameters = $Parameters | 
                Select-Object -Property *, @{l = 'Order'; e = { if ($_.Position -lt 0) { $LastOrder + 1 } else { $_.Position } } } |
                Sort-Object Order
            }
            else {
                $SortedParameters = $Parameters | Sort-Object Position
            }

            Foreach ($p in $SortedParameters) {
                $l = $length - $p.Name.Length
		
                if ($p.ParameterType.Name -eq 'SwitchParameter') {
                    $setBlock.Add("[Boolean]`$$($p.Name) = `$false # Switch")
                }
                else {
                    $setBlock.Add("[$($p.ParameterType)]`$$($p.Name) = ''")	
                }
		
                [string]$row = "`t$($p.Name)$(' ' * $l) = `$$($p.Name)"
                if ($p.IsMandatory -eq $true) {
                    $row += "$(' ' * $l) #Required"
                }
                $hashBlock.Add($row)
            }
            $hashBlock.Add('}')
            $hashBlock.Add("$command @$($hash)$($set.Name)")
            [SplatBlock]@{
                Command      = $Command
                ParameterSet = $set.Name
                IsDefault    = $set.IsDefault
                HashBlock    = ($hashBlock -join ("`n"))
                SetBlock     = ($setBlock -join ("`n"))
            }
        }
    }

    if($Copy -eq $true){
        $Output | Select-Object -First 1 | ForEach-Object{
            "$($_.SetBlock)`n$($_.HashBlock)" | Set-Clipboard
        }
    }

    $Output
}