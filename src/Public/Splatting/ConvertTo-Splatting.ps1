<#
.SYNOPSIS
Converts an existing PowerShell command into a splatting hashtable and splatted command.

.DESCRIPTION
ConvertTo-Splatting takes a PowerShell command provided as a string or script block and rewrites it
into a splatting-friendly format. It parses the command, identifies the command name and parameters,
and produces:

- A hashtable assignment (for example, $GetItemParam = @{ ... })
- A command invocation that uses splatting (for example, Get-Item @GetItemParam)

This is useful for refactoring long command lines into a clearer, more maintainable structure, and for
turning backtick-continued commands into a single normalized form.

.FUNCTIONALITY
PowerShell Utilities

.ROLE
Utility

.COMPONENT
Splatting

.PARAMETER Command
The command text to convert to splatting. Provide a full command line as a string.

.PARAMETER ScriptBlock
The command to convert to splatting, provided as a script block. The script block is converted to text
and normalized prior to parsing.

.EXAMPLE
$splatme = @'
Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx"} `
    -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
'@
ConvertTo-Splatting $splatme

Creates a parameter hashtable and a splatted Set-AzVMExtension call.

.EXAMPLE
$splatme = { Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf }
ConvertTo-Splatting $splatme

Converts a script block command into a hashtable and a splatted Copy-Item call. Switch parameters are
represented as $true.

.EXAMPLE
$splatme = {
    Get-AzVM `
        -ResourceGroupName "ResourceGroup11" `
        -Name "VirtualMachine07" `
        -Status
}
ConvertTo-Splatting $splatme

Normalizes backtick line continuations and converts the command to splatting.

.NOTES
- If the command starts with a variable assignment, the variable(s) are preserved as part of the parsed command.
- The hashtable variable name is derived from the command name (for example, Get-Item -> $GetItemParam). If that
  name conflicts with an existing constant variable, a fallback name is used.
- For background on splatting, see:
  about_Splatting - https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_splatting
#>
Function ConvertTo-Splatting {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'string', Position = 0)]
        [string] $Command,
        [Parameter(ParameterSetName = 'scriptblock', Position = 0)]
        [ScriptBlock] $ScriptBlock
    )

    # Convert scriptblock to string for parsing
    if ($PSCmdlet.ParameterSetName -eq 'scriptblock') {
        $Command = $ScriptBlock.ToString().Trim()
    }
    # remove backticks 
    $ScriptBlockAst = [regex]::Replace($Command, '(`\r\n|`\r|`\n)', ' ')

    # Parse the script block input
    $Errors = @()
    $ref = @()
    [void][System.Management.Automation.Language.Parser]::ParseInput($ScriptBlockAst, [ref]$ref, [ref]$Errors)

    # Get the command and any variables it is being set to
    [System.Collections.Generic.List[string]]$ParsedCommand = @()
    $index = $ref | Where-Object { $_.TokenFlags -eq 'CommandName' } | Select-Object -First 1
    for ($i = 0; $i -le $ref.IndexOf($index); $i++) {
        if ($ref[$i].TokenFlags -notin 'None', 'AssignmentOperator', 'CommandName') {
            throw "Command should only start with a cmdlet or variable declaration '$($ref[$i].TokenFlags)'"
        }
        $ParsedCommand.Add($ref[$i].Text)
    }

    # set a name to make the hashtable variable
    $hash = $index.Value.Replace('-', '') + 'Param'
    $constants = (Get-Variable | Where-Object { $_.Options -match 'Constant' }).Name
    if ($ref[0].Name -eq $hash -or $hash -in $constants) {
        $hash = 'parameterSplat'
    }

    # Get all the parameters and their values
    [System.Collections.Generic.List[PSObject]]$parameters = @()
    $parametersExpected = $true
    $LParen = 0
    for ($i = $ParsedCommand.Count; $i -lt $ref.Count; $i++) {
        if ($ref[$i].Kind -eq 'EndOfInput') {
            $parameters[-1].End = $i
        }
        elseif ($LParen -eq 0 -and $ref[$i].Kind -eq 'Parameter') {
            # default value to $true to account for switches
            if ($parameters.Count -gt 0) {
                $parameters[-1].End = $i
            }
            [System.Collections.Generic.List[PSObject]] $Value = @()
            $parameters.Add([pscustomobject]@{Name = $ref[$i].ParameterName; Value = $Value; Start = $i + 1; End = 0 })
            $parametersExpected = $false
        }
        elseif ($ref[$i].Kind -in 'RParen', 'RCurly') {
            $LParen--
        }
        elseif ($LParen -eq 0 -and $parametersExpected -eq $true) {
            # if parameter was expected but not passed get the parameter name based on the position
            try {
                $ParsedCommandData = Get-Command -Name $index.Value -ErrorAction Stop
            }
            catch {
                if ($_.FullyQualifiedErrorId -eq 'CommandNotFoundException,Microsoft.PowerShell.Commands.GetCommandCommand') {
                    throw "Unable to find parameters for the command '$($index.Value)' ensure all modules and functions are loaded before retrying."
                }
                break
            }
            # using alias get the actual command resolves
            if ($ParsedCommandData.CommandType -eq 'Alias') {
                $ParsedCommandData = Get-Command -Name $ParsedCommandData.ResolvedCommand
            }
            # get the default Parameters
            if ($ParsedCommandData.ParameterSets.Count -gt 1) {
                $ParameterSet = foreach ($set in $ParsedCommandData.ParameterSets) {
                    $setParameters = $set.Parameters | Foreach-Object { $_.Name; $_.Aliases }
                    if ($parameters | Where-Object { $_.Name -notin $setParameters }) {
                        # Do nothing
                    }
                    else {
                        $set
                    }
                }
                if ($ParameterSet.Count -gt 1) {
                    $ParameterSet = $ParameterSet | Where-Object { $_.IsDefault }
                    if ($ParameterSet.Count -gt 1) {
                        $ParameterSet = $ParameterSet[0]
                    }
                }
                if (-not $ParameterSet) {
                    $ParameterSet = $ParsedCommandData.ParameterSets | Where-Object { $_.IsDefault }
                }
                
                if (-not $ParameterSet) {
                    $ParameterSet = $ParsedCommandData.ParameterSets[0]
                }
            }
            else {
                $ParameterSet = $ParsedCommandData.ParameterSets
            }
            # Get the parameter name based on the position number
            $ParameterName = ($ParameterSet.Parameters | Where-Object { $_.Position -eq $parameters.Count }).Name
            # if the position does not match, get the parameter from the array value
            if ([string]::IsNullOrEmpty($ParameterName)) {
                $ParameterName = ($ParameterSet.Parameters[$parameters.Count]).Name
            }
            if ($parameters.Count -gt 0) {
                $parameters[-1].End = $i
            }
            [System.Collections.Generic.List[PSObject]] $Value = @()
            $parameters.Add([pscustomobject]@{Name = $ParameterName; Value = $Value; Start = $i; End = 0 })
        }
        elseif ($LParen -eq 0 -and $ref[$i].Kind -notin 'Dot', 'LParen', 'DollarParen', 'AtCurly') {
            $parametersExpected = $true
        }
        Write-Debug "$LParen $parametersExpected - $($ref[$i].Text) - $($ref[$i].Kind)"
        if ($ref[$i].Kind -in 'LParen', 'DollarParen', 'AtCurly') {
            $LParen++
        }
        elseif ($ref[$i + 1].Kind -eq 'Dot') {
            $parametersExpected = $false
        }
    }


    foreach ($p in $parameters) {
        for ($i = $p.Start; $i -lt $p.End; $i++) {
            Write-Debug "$($ref[$i].Text) - $($ref[$i].Kind)"
            if ($ref[$i].Kind -in 'Identifier', 'Generic' -and $ref[$i].TokenFlags -ne 'CommandName') {
                # check if the value is in quotes and add them if not
                if ($ref[$i].Text[0] -notin '"', "'" -and ($p.End - $p.Start) -eq 1) {
                    $p.Value.Add("'$($ref[$i].Text.Replace("'","''"))'")
                }
                else {
                    $p.Value.Add($ref[$i].Text)
                }
            }
            elseif ($ref[$i].Kind -notin 'EndOfInput', 'Parameter') {
                $p.Value.Add($ref[$i].Text)
            }
        }
    }
    $parameters | Where-Object { $_.Start -eq $_.End -and $_.Value.Count -eq 0 } | ForEach-Object { $_.Value.Add('$true') }

    $spacing = ($parameters.Name | Measure-Object -Maximum -Property Length).Maximum
    $spacing++

    [System.Collections.Generic.List[PSObject]] $output = @()
    # build the output
    $output.Add("`$$($hash) = @{")
    $parameters | ForEach-Object {
        $output.Add(("`t$($_.Name)$(' '*$($spacing - $_.Name.Length))= $($_.Value -join(' '))").Replace(' . ', '.'))
    } 
    $output.Add("}")
    # if there were pipelines add them back in
    if ($Split.Count -gt 1) {
        $pipes = $Split[1..($Split.Length - 1)]
        $output.Add((@("$($ParsedCommand) @$($hash)") + @($pipes)) -join (' | '))
    }
    else {
        $output.Add("$($ParsedCommand) @$($hash)")
    }
    
    $return = [SplatBlock]@{
        Command   = $index.Value
        IsDefault = $null
        HashBlock = ($output -join ("`n"))
        SetBlock  = $null
    }

    
    $return.HashBlock | Set-Clipboard

    $return
}