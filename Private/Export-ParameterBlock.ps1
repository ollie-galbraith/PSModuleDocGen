Function Export-ParameterBlock
    {
        <#
        .SYNOPSIS
        Exports all the parameters and their options for each cmdlet in a specified module

        .EXAMPLE
        Export-ParameterBlock -CmdletPath <Path to cmdlet> -Format $true
        #>

        param(
            [Parameter(Mandatory=$true, Position=0, HelpMessage="The file path to the module to extract parameters from.")]
            [string]$CmdletPath,
            [Parameter(Mandatory=$false, Position=1, HelpMessage="Indicates whether to format the output.")]
            [Boolean]$Format = $true
        )

        $StringBlock = ''

        $Parameter = Get-Parameters -CmdletPath $CmdletPath

        If($Null -eq $Parameter.Parameters)
            {
                Return $Null
            }

        $LongestParameterName = ($Parameter.Parameters.Name | Sort-Object Length -Descending | Select-Object -First 1).Length
        $LongestParameterType = ($Parameter.Parameters.Type | Sort-Object Length -Descending | Select-Object -First 1).Length

        $ParameterSetNames = $Parameter.Parameters.Options.ParameterSetName | Sort-Object -Unique

        If($ParameterSetNames.Count -eq 0)
            {
                $StringBlock += "$($Parameter.Name)`n"
                $StringBlock += "`n"

                ForEach($ParameterObject in $Parameter.Parameters)
                    {
                        $Spaces = (($LongestParameterName - $ParameterObject.Name.Length) + ($LongestParameterType - $ParameterObject.Type.Length)) + 1
                        If($Format -eq $false)
                            {
                                $Spaces = 1
                            }

                        If($ParameterObject.Type -eq 'Non Specified')
                            {
                                $StringBlock += "`t[-$($ParameterObject.Name)$(" " * $Spaces)<[ ]>]`n"
                            }
                        Else
                            {
                                $StringBlock += "`t[-$($ParameterObject.Name)$(" " * $Spaces)<$($ParameterObject.Type)[ ]>]`n"
                            }
                    }
                $StringBlock += "`t[<CommonParameters>]`n`n`n"
            }
        Else
            {
                ForEach($ParameterSetName in $ParameterSetNames)
                    {
                        $StringBlock += "$($Parameter.Name)`n"
                        $StringBlock += "`n"

                        ForEach($ParameterObject in $Parameter.Parameters)
                            {
                                $ParameterObjectParameterSetName = $ParameterObject.Options.ParameterSetName | Sort-Object -Unique

                                If(($ParameterObjectParameterSetName -eq $ParameterSetName) -or ($null -eq $ParameterObject.Options.ParameterSetName))
                                    {
                                        $Spaces = (($LongestParameterName - $ParameterObject.Name.Length) + ($LongestParameterType - $ParameterObject.Type.Length)) + 1

                                        If($Format -eq $false)
                                            {
                                                $Spaces = 1
                                            }

                                        If($ParameterObject.Type -eq 'Non Specified')
                                            {
                                                $StringBlock += "`t[-$($ParameterObject.Name)$(" " * $Spaces)<[ ]>]`n"
                                            }
                                        Else
                                            {
                                                $StringBlock += "`t[-$($ParameterObject.Name)$(" " * $Spaces)<$($ParameterObject.Type)[ ]>]`n"
                                            }
                                    }
                            }
                        $StringBlock += "`t[<CommonParameters>]`n`n`n"
                    }
            }

        $Object = [pscustomobject]@{
            "CmdletName" = $($Parameter.Name)
            "Block" = $StringBlock.Trim()
            "ParameterInfo" = $($Parameter.Parameters)
        }

        Return $Object
    }