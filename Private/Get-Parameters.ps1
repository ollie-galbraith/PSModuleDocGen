Function Get-Parameters
    {
        <#
        .SYNOPSIS
        Extracts parameter information from a PowerShell function script file, including both static and dynamic parameters.
        .EXAMPLE
        Get-Parameters -CmdletPath C:\Path\To\Your\Cmdlet.ps1
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, Position=0, HelpMessage="The file path to the PowerShell function script file to extract parameters from.")]
            [string]$CmdletPath
        )

        $Body = Get-Content $CmdletPath -Raw -Encoding UTF8
        $Body = $Body -replace '^\s*function\s+\S+\s*{', ''
        $Body = $Body -replace '}\s*$', ''
        $Body = $Body.Trim()


        $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::ParseInput($Body, [ref]$null, [ref]$null)

        If($Errors.Count -gt 0)
            {
                Throw "Parse errors in $CmdletPath"
            }

        # --- Static parameters ---
        $ParamBlock = $AbstractSyntaxTree.ParamBlock
        $DynamicParamAst = $AbstractSyntaxTree.DynamicParamBlock

        [System.Collections.ArrayList]$ParameterArrayList = @()

        [System.Collections.Generic.List[string]]$ExcludedParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        If($ParamBlock)
            {
                ForEach($Parameter in $ParamBlock.Parameters)
                    {
                        # Parameter name
                        $Name = $Parameter.Name.VariablePath.UserPath
                        $Type = If($Parameter.StaticType) { $Parameter.StaticType.FullName } Else { 'Non Specified' }
                        $DefaultValue = If($Parameter.DefaultValue) { $Parameter.DefaultValue } Else { $null }

                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parameter Name: $Name"
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parameter Type: $Type"
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parameter DefaultValue: $DefaultValue"

                        [System.Collections.ArrayList]$ParameterOptions = @()
                        ForEach($Attribute in $Parameter.Attributes)
                            {
                                $AttributeName = $Attribute.TypeName.Name
                                If(@('Parameter','ValidateSet', 'ValidateRange', 'ValidateScript') -notcontains $AttributeName)
                                    {
                                        Continue
                                    }

                                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parameter attribute name: $AttributeName"
                                $Options = @{}

                                # Named arguments (eg Mandatory=$true)
                                ForEach($Named in $Attribute.NamedArguments)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parameter named argument: $Named"
                                        $Options[$Named.ArgumentName] = $Named.Argument.Extent.Text.Trim("'")
                                    }

                                # Positional args (eg ValidateSet('a','b'))
                                If($Attribute.PositionalArguments.Count -gt 0)
                                    {
                                        $Options[$AttributeName] = $Attribute.PositionalArguments | ForEach-Object { $_.Extent.Text.Trim("'") }
                                    }

                                [void]$ParameterOptions.Add($Options)
                            }

                        [void]$ParameterArrayList.Add([pscustomobject]@{
                            Name         = $Name
                            Type         = $Type
                            DefaultValue = $DefaultValue
                            Options      = $ParameterOptions
                        })
                    }
            }

        # --- Dynamic parameters ---
        If($DynamicParamAst)
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Found DynamicParam block, extracting dynamic parameters..."

                # Keep track of already added names
                $ExistingNames = $ParameterArrayList | Select-Object -ExpandProperty Name

                $Command = Get-Command -Name ((Get-Item $CmdletPath).BaseName) -ErrorAction SilentlyContinue
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Command parameters: $($Command.Parameters.Keys -join ', ')"
                ForEach($RuntimeParam in $Command.Parameters.Values)
                    {
                        If(($ExcludedParameters -contains $RuntimeParam.Name) -or ($ExistingNames -contains $RuntimeParam.Name))
                            {
                                Continue
                            }

                        $Name = $RuntimeParam.Name
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Dynamic Parameter Name: $Name"
                        $Type = If($RuntimeParam.ParameterType) { $RuntimeParam.ParameterType.Name } Else { 'Non Specified' }
                        $DefaultValue = If($RuntimeParam.DefaultValue) { $RuntimeParam.DefaultValue } Else { $null }

                        # Collect Options from Attributes
                        $Options = @{}
                        ForEach($Attribute in $RuntimeParam.Attributes)
                            {
                                # Named arguments
                                ForEach($Property in $Attribute.PSObject.Properties)
                                    {
                                        $Options[$Property.Name] = $Property.Value
                                    }
                            }

                        [void]$ParameterArrayList.Add([pscustomobject]@{
                            Name         = $Name
                            Type         = $Type
                            DefaultValue = $DefaultValue
                            Options      = $Options
                        })
                    }
            }

        If($ParameterArrayList.Count -ne 1)
            {
                $ParameterArrayList = $ParameterArrayList | Sort-Object {$_.Options.Position}
            }

        Return [pscustomobject]@{
            Name       = $CmdletName
            Parameters = $ParameterArrayList
        }
    }