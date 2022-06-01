Function Write-Splatting {
    <#
    .SYNOPSIS
    Use to convert an existing PowerShell command to splatting

    .DESCRIPTION
    Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick.
    This function excepts any command as a string or a scriptblock and will convert the existing parameters
    to a hashtable and output the fully splatted command for you.

    .PARAMETER Command
    The command string you want to convert to using splatting

    .PARAMETER ScriptBlock
    The command scriptblock you want to convert to using splatting

    .EXAMPLE
    Converts the string splatme to splatting
    $splatme = @'
    Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
    '@
    Write-Splatting $splatme

    --- Output ----
    $SetAzVMExtensionParam = @{
            ExtensionName      = "MicrosoftMonitoringAgent"
            ResourceGroupName  = "rg-xxxx"
            VMName             = "vm-xxxx"
            Publisher          = "Microsoft.EnterpriseCloud.Monitoring"
            ExtensionType      = "MicrosoftMonitoringAgent"
            TypeHandlerVersion = "1.0"
            Settings           = @{ "workspaceId" = "xxxx" }
            ProtectedSettings  = @{ "workspaceKey" = "xxxx" }
            Location           = "uksouth"
    }
    Set-AzVMExtension @SetAzVMExtensionParam

    .EXAMPLE
    Converts the scriptblock splatme to splatting
    $splatme = {
        Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
    }
    Write-Splatting $splatme

    --- Output ----
    $CopyItemParam = @{
            Path        = "test.txt"
            Destination = "test2.txt"
            WhatIf      = $true
    }
    Copy-Item @CopyItemParam

    .EXAMPLE
    Removed backticks and converts the scriptblock splatme to splatting
    $splatme = {
        Get-AzVM `
            -ResourceGroupName "ResourceGroup11" `
            -Name "VirtualMachine07" `
            -Status
    }
    Write-Splatting $splatme

    --- Output ----
    $GetAzVMParam = @{
        ResourceGroupName = "ResourceGroup11"
        Name              = "VirtualMachine07"
        Status            = $true
    }
    Get-AzVM @GetAzVMParam

    .NOTES
    about_Splatting - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting
    #>
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
    
    [SplatBlock]@{
        Command   = $index.Value
        IsDefault = $null
        HashBlock = ($output -join ("`n"))
        SetBlock  = $null
    }
}