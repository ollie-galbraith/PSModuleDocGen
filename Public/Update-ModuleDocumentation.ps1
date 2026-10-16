Function Update-ModuleDocumentation
    {
        <#
        .SYNOPSIS
        This function updates the documentation for a specified PowerShell module. It can use either the module's path or name to locate the module and generate the documentation.
        .EXAMPLE
        # Update documentation for a module using the module path
        Update-ModuleDocumentation -Path "C:\Users\ogalbraith\Documents\WindowsPowerShell\Modules\PSModuleDocGen"
        .EXAMPLE
        # Update documentation for a module using the module name
        Update-ModuleDocumentation -Name "PSModuleDocGen"
        #>

        [CmdletBinding(DefaultParameterSetName="ModuleName")]
        param(
            [Parameter(Mandatory=$true, ParameterSetName="ModulePath", Position=0, HelpMessage="The file path to the module to document")]
            [string]$Path,
            [Parameter(Mandatory=$false, Position=1, HelpMessage="The description of the module")]
            [string]$Description,
            [Parameter(Mandatory=$false, Position=2, HelpMessage="Show the output of the documentation generation process in the console")]
            [boolean]$ShowOutput = $False
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $AvailableModules = Get-Module | Select-Object -ExpandProperty Name

                $ParamList = @(
                    @{
                        ParameterName    = 'Name'
                        ParameterType    = ([string])
                        Mandatory        = $true
                        ValidateSet      = [array]$AvailableModules
                        HelpMessage      = "The name of the module to document. This will be used to find the module path. This parameter is not required if the ModulePath parameter is used."
                        Position         = 0
                        ParameterSetName = 'ModuleName'
                    }
                )

                ForEach($Param in $ParamList)
                    {
                        Add-DynamicParameter @NewDynamicParams @Param
                    }
                Return $DynamicParameterDictionary
            }

        Begin
            {
                If($PSCmdlet.ParameterSetName -eq "ModuleName")
                    {
                        $Name = $DynamicParameterDictionary['Name'].Value
                        $ModuleInfo = Get-Module -Name $Name | Select-Object -First 1
                        If($null -eq $ModuleInfo)
                            {
                                Write-Error "Unable to find module with name '$Name'"
                                Break
                            }
                        $Path = $ModuleInfo.ModuleBase
                    }
                ElseIf($PSCmdlet.ParameterSetName -eq "ModulePath")
                    {
                        $Path = $Path.TrimEnd('\').TrimEnd('/')
                    }
            }

        Process
            {
                If([String]::IsNullOrEmpty($Path))
                    {
                        Write-Error "Module path is required. Please provide a valid path to the module."
                        Break
                    }

                $ItemInfo = Get-Item -Path $Path
                If($ItemInfo.PSIsContainer -eq $true)
                    {
                        $ModuleManifestPath = Get-ChildItem -Path $Path -Filter "*.psd1" | Select-Object -ExpandProperty Fullname
                    }
                ElseIf(($ItemInfo.PSIsContainer -eq $false) -and ($Path -notlike "*.psm1"))
                    {
                        Write-Error "Unable to find correct module file"
                        Break
                    }

                $ModuleName = $Path | Split-Path -Leaf

                If($PSBoundParameters.Keys -notcontains 'Description')
                    {
                        $ManifestInfo = Import-PowerShellDataFile -Path $ModuleManifestPath
                        $Description = $ManifestInfo.Description
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Module description pulled from manifest file"
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $Description"
                    }

                $DocsPath = 'docs/cmdlets'

                $AbsolutePath = (Get-Item -Path $Path).FullName
                $FileOutput = "$AbsolutePath/README.md"

                $PublicCmdletFiles = Get-ChildItem -Path "$AbsolutePath/Public" -Recurse -Filter "*.ps1" | Sort-Object -Property Name
                $PrivateCmdletFiles = Get-ChildItem -Path "$AbsolutePath/Private" -Recurse -Filter "*.ps1" | Sort-Object -Property Name

                $MarkdownContent = ""
                $MarkdownContent += "### $ModuleName`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "##### Description`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "$Description"
                $MarkdownContent += "`n"
                $MarkdownContent += "*****`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "##### Available Cmdlets`n"

                ForEach($Cmdlet in $PublicCmdletFiles)
                    {
                        $OutputFile = $Cmdlet.Fullname -replace "Public(/.*)?/$($Cmdlet.Name)", "$DocsPath/$($Cmdlet.Name.Replace('.ps1','.md'))"

                        New-FunctionMarkdownDoc -FunctionPath $Cmdlet.FullName -OutputPath $OutputFile -ShowOutput $ShowOutput -ErrorAction Stop

                        $MarkdownContent += "+ [$($Cmdlet.BaseName)]($DocsPath/$($Cmdlet.Name.Replace('.ps1','.md')))`n"
                    }

                If($PrivateCmdletFiles.Count -gt 0)
                    {
                        $MarkdownContent += "`n"
                        $MarkdownContent += "##### Private Functions`n"

                        ForEach($Cmdlet in $PrivateCmdletFiles)
                            {
                                $OutputFile = $Cmdlet.Fullname -replace "Private(/.*)?/$($Cmdlet.Name)", "$DocsPath/Private/$($Cmdlet.Name.Replace('.ps1','.md'))"

                                New-FunctionMarkdownDoc -FunctionPath $Cmdlet.FullName -OutputPath $OutputFile -ShowOutput $ShowOutput -ErrorAction Stop

                                $MarkdownContent += "+ [$($Cmdlet.BaseName)]($DocsPath/Private/$($Cmdlet.Name.Replace('.ps1','.md')))`n"
                            }
                    }

                $MarkdownContent += "`n"
                $MarkdownContent += "*****`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "##### Usage`n"
                $MarkdownContent += "To install and use this module, use the following code`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "``````powershell`n"
                $MarkdownContent += "PS C:\> Install-Module -Name $ModuleName`n"
                $MarkdownContent += "`n"
                $MarkdownContent += "PS C:\> Import-Module -Name $ModuleName`n"
                $MarkdownContent += "``````"


                $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
                [System.IO.File]::WriteAllLines($FileOutput, $MarkdownContent, $Utf8NoBomEncoding)
            }
    }