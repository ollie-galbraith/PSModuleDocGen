Function New-FunctionMarkdownDoc
    {
        <#
        .SYNOPSIS
        Generates markdown documentation for a PowerShell function script.
        .EXAMPLE
        New-FunctionMarkdownDoc -FunctionPath 'C:\Users\ogalbraith\Documents\WindowsPowerShell\Modules\PSModuleDocGen\Public\Get-Parameters.ps1'
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, Position=0, HelpMessage="The file path to the PowerShell function file.")]
            [ValidatePattern('^.+\.ps1$')]
            [string]$FunctionPath,
            [ValidatePattern('^.+\.md$')]
            [Parameter(Mandatory=$false, Position=1, HelpMessage="The file path to output the generated markdown documentation to. If not specified, the markdown file will be created in the same directory as the function file with the same name and a .md extension.")]
            [string]$OutputPath,
            [Parameter(Mandatory=$false, Position=2, HelpMessage="Output the generated markdown content to the console instead of writing to a file")]
            [Switch]$Output,
            [Parameter(Mandatory=$false, Position=3, HelpMessage="Show the output of the documentation generation process in the console")]
            [boolean]$ShowOutput = $False
        )

        If ($PSBoundParameters['Debug']) {$DebugPreference = 'Continue'}

        Add-Type -AssemblyName System.Web

        $CmdletFile = Get-Item -Path $FunctionPath

        $CmdletName = $CmdletFile.BaseName
        $CmdletSynopsis = Get-CmdletSynopsis -CmdletPath $CmdletFile.FullName
        $CmdletExample = Get-CmdletExample -CmdletPath $CmdletFile.FullName
        $CmdletParameters = Export-ParameterBlock -CmdletPath $CmdletFile.FullName

        $ExampleBlock = ""
        $ParameterBlock = ""

        ForEach($Example in $CmdletExample.Example)
            {
                $ExampleBlockString = "
                    #### Example $($CmdletExample.Example.IndexOf($Example) + 1)
                    ``````powershell
                    $($Example.Replace("__newline__","`n"))
                    ``````
                "
                $ExampleBlockString = Format-TabbedString -String $ExampleBlockString
                $ExampleBlock += $ExampleBlockString
            }

        $ExampleBlock = $ExampleBlock.TrimEnd("`n")

        $Regex = '([\\_^|{])'

        If($Null -ne $CmdletParameters)
            {
                ForEach($Parameter in ($CmdletParameters.ParameterInfo | Sort-Object -Property Name))
                    {
                        ForEach($OptionSet in $Parameter.Options)
                            {
                                If($null -eq $OptionSet.Mandatory)
                                    {
                                        $Mandatory = [bool]::FalseString
                                    }
                                Else
                                    {
                                        If($OptionSet.Mandatory -is [string])
                                            {
                                                $Mandatory = [bool]::Parse($OptionSet.Mandatory.Trim('$'))
                                            }
                                        Else
                                            {
                                                $Mandatory = [bool]$OptionSet.Mandatory
                                            }
                                    }

                                $ParameterTable = "
                                    | | |
                                    |-|-|
                                    | Type | $($Parameter.Type) |
                                    | Mandatory | $Mandatory |
                                "
                                $ParameterTable = Format-TabbedString -String $ParameterTable

                                If($Parameter.DefaultValue)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Default Value found for parameter $($Parameter.Name): $($Parameter.DefaultValue)"
                                        $ParameterTable += "| DefaultValue | $($Parameter.DefaultValue) |`r`n"
                                    }
                                If($OptionSet.ValidateSet)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] ValidateSet found for parameter $($Parameter.Name): $($OptionSet.ValidateSet -join ', ')"
                                        $ParameterTable += "| ValidateSet | $($OptionSet.ValidateSet -join ', ') |`r`n"
                                    }
                                If($OptionSet.ValidateRange)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] ValidateRange found for parameter $($Parameter.Name): $($OptionSet.ValidateRange -join ', ')"
                                        $ParameterTable += "| ValidateRange | $($OptionSet.ValidateRange -join ', ') |`r`n"
                                    }
                                If($OptionSet.ValidatePattern)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] ValidatePattern found for parameter $($Parameter.Name): $($OptionSet.ValidatePattern)"
                                        $Result = [System.Text.RegularExpressions.Regex]::new($Regex).Replace($OptionSet.ValidatePattern, '\$1')
                                        $ParameterTable += "| ValidatePattern | <pre><code class=`"language-powershell`">$Result</code></pre> |`r`n"
                                    }
                                If($OptionSet.ValidateScript)
                                    {
                                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] ValidateScript found for parameter $($Parameter.Name): $($OptionSet.ValidateScript)"
                                        $ValidateScriptString = [System.Web.HttpUtility]::HtmlEncode($OptionSet.ValidateScript.Trim("`r`n")) -replace "`r`n", '<br>' -replace "`n", '<br>' -replace "`t", '&#09;' -replace "&#39;","'"
                                        $Result = [System.Text.RegularExpressions.Regex]::new($Regex).Replace($ValidateScriptString, '\$1')

                                        $ParameterTable += "| ValidateScript | <pre><code class=`"language-powershell`">$Result</code></pre> |`r`n"
                                    }
                            }

                        If($Parameter.Options.ParameterSetName)
                            {
                                Write-Verbose "[$($MyInvocation.MyCommand.Name)] ParameterSetNames found for parameter $($Parameter.Name): $($Parameter.Options.ParameterSetName -join ', ')"
                                $SetNames = ($Parameter.Options.ParameterSetName | Sort-Object -Unique) -join ', '
                                $ParameterTable += "| ParameterSetNames | $($SetNames.Replace('"', '')) |`r`n"
                            }

                        $ParameterTable = Format-MarkDownTable -Table $ParameterTable

                        $ParameterBlock += "#### -$($Parameter.Name)`n"
                        If($Parameter.Options.HelpMessage)
                            {
                                $ParameterBlock += "`n"
                                $HelpMessageString = $Parameter.Options.HelpMessage | Select-Object -Unique
                                $ParameterBlock += "$($HelpMessageString.Trim('"'))`n`n"
                            }

                        $ParameterBlock += $ParameterTable
                        $ParameterBlock += "`n`n"
                    }
            }

        If($PSBoundParameters.Keys -contains "OutputPath")
            {
                $FileOutput = $OutputPath
            }
        Else
            {
                $FileOutput = $FunctionPath.Replace(".ps1",".md")
            }

        $FileOutputParent = $FileOutput | Split-Path -Parent

        # Build markdown source-link path relative to the output markdown directory.
        $OutputDirectory = [System.IO.Path]::GetFullPath($FileOutputParent)
        $FunctionFullPath = [System.IO.Path]::GetFullPath($CmdletFile.FullName)

        $OutputDirectoryUri = [System.Uri]::new(($OutputDirectory.TrimEnd('\') + '\'))
        $FunctionUri = [System.Uri]::new($FunctionFullPath)

        $MarkdownContent = "
            ## $CmdletName

            ### Description

            <<<synopsis>>>

            ---

            ``````
            <<<parameters>>>

            ``````

            ---

            ### Source Code
            <<<source_code_link>>>

            ### Examples

            <<<examples>>>

            ---

            ### Parameters

            <<<parameter_tables>>>
        "

        $MarkdownContent = Format-TabbedString -String $MarkdownContent

        $MarkdownContent = $MarkdownContent -creplace '<<<synopsis>>>', $($CmdletSynopsis.Synopsis)
        $MarkdownContent = $MarkdownContent -creplace '<<<source_code_link>>>', "[$($CmdletName).ps1]($([System.Uri]::UnescapeDataString($OutputDirectoryUri.MakeRelativeUri($FunctionUri).ToString())))"

        If($Null -ne $CmdletParameters)
            {
                $MarkdownContent = $MarkdownContent -creplace '<<<parameters>>>', $($CmdletParameters.Block)
                $MarkdownContent = $MarkdownContent -creplace '<<<parameter_tables>>>', "$($ParameterBlock)"
            }
        Else
            {
                # Remove parameter blocks from markdown
                # $MarkdownContent = $MarkdownContent -replace "\s<<<parameters>>>\s*","" -replace "``````\s*", "" -replace "---\s*", ""
                $MarkdownContent = $MarkdownContent -replace "---\s+``````\s+<<<parameters>>>\s+``````\s+---\s+",""
                $MarkdownContent = $MarkdownContent -replace "---\s*#+ Parameters\s*<<<parameter_tables>>>\s*", ""
            }

        $MarkdownContent = $MarkdownContent -creplace '<<<examples>>>', "$($ExampleBlock)"

        $MarkdownContent = $MarkdownContent.Trim()

        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

        If($Output -eq $false)
            {
                If((Test-Path -Path $FileOutputParent) -eq $false)
                    {
                        New-Item -Path $FileOutputParent -ItemType Directory | Out-Null
                    }

                [System.IO.File]::WriteAllLines($FileOutput, $MarkdownContent, $Utf8NoBomEncoding)

                If($ShowOutput -eq $True)
                    {
                        Return Get-Item -Path $FileOutput
                    }
            }
        Else
            {
                Return $MarkdownContent
            }
    }