<#
.SYNOPSIS
Generates a splatting template for a PowerShell command.

.DESCRIPTION
Get-CommandSplatting inspects a command’s parameter metadata and produces a ready-to-paste splatting
template. It returns one or more objects that include:

- A variable “set block” with typed variable declarations for each parameter
- A hashtable “hash block” formatted for splatting (including required-parameter comments)
- A final example invocation that splats the hashtable into the command

By default, the cmdlet outputs the default parameter set for the command. You can list available
parameter sets, generate a specific parameter set, or generate templates for all parameter sets.
Optionally include the PowerShell common parameters and/or copy the first generated template to the
clipboard.

.FUNCTIONALITY
PowerShell Utilities

.ROLE
Utility

.COMPONENT
Splatting

.PARAMETER Command
The name of the command to generate a splatting template for (cmdlet/function/alias supported by Get-Command).

.PARAMETER ParameterSet
The name of a specific parameter set to generate. Use -ListParameterSets to discover available names.

.PARAMETER ListParameterSets
Lists available parameter sets for the specified command, including whether each set is the default and the
parameter names in that set.

.PARAMETER All
Generates splatting templates for all parameter sets for the specified command.

.PARAMETER IncludeCommon
Includes PowerShell common parameters (for example: Verbose, Debug, ErrorAction) in the generated output.

.PARAMETER Copy
Copies the first generated template (SetBlock + HashBlock) to the clipboard.

.EXAMPLE
Get-CommandSplatting -Command 'Get-Item'

Generates a splatting template for the default parameter set of Get-Item.

.EXAMPLE
Get-CommandSplatting -Command 'Get-Item' -ListParameterSets

Lists the available parameter sets for Get-Item and shows the parameters included in each set.

.EXAMPLE
Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath

Generates a splatting template for the LiteralPath parameter set.

.EXAMPLE
Get-CommandSplatting -Command 'Get-Item' -All

Generates splatting templates for all parameter sets of Get-Item.

.EXAMPLE
Get-CommandSplatting -Command 'Get-Item' -IncludeCommon -Copy

Generates the default parameter set template including common parameters and copies the first template to the clipboard.

.OUTPUTS
SplatBlock

.NOTES
- Required parameters are annotated in the hashtable output with a "#Required" comment.
- Switch parameters are represented as [Boolean] variables in the set block, defaulting to $false.
- Use -ListParameterSets to discover parameter set names before using -ParameterSet.
#>
Function Get-CommandSplatting {
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