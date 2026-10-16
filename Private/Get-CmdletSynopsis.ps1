Function Get-CmdletSynopsis
    {
        <#
        .Synopsis
        Extracts the synopsis from a PowerShell function script file.
        .Example
        Get-CmdletSynopsis -CmdletPath "C:\Users\ogalbraith\Desktop\Powershell\Modules\PSModuleDocGen\Format-MarkdownTable.ps1"
        #>

        param(
            [Parameter(Mandatory=$true, Position=0, HelpMessage="The file path to the PowerShell function script file to extract the synopsis from.")]
            [string]$CmdletPath
        )

        $SynopsisRegex = '(?i)(?<=\.SYNOPSIS)(.|\r|\n)+?(?=((\n|\r)\.))'

        $CmdletContent = Get-Content -Path $CmdletPath -Encoding UTF8

        $LineNumber = 0
        ForEach($Line in $CmdletContent)
            {
                If($Line -match "<#")
                    {
                        $BlockStart = $LineNumber
                    }
                ElseIf($Line -match "#>")
                    {
                        $BlockEnd = $LineNumber
                    }
                $LineNumber += 1
            }

        $CommentBlock = $CmdletContent[$BlockStart..$BlockEnd]
        $JoinedCommentBlock = $CommentBlock -join "`r`n"

        $FormattedCommentBlock = Format-TabbedString -String $JoinedCommentBlock -Verbose:$False

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Parsing cmdlet file $CmdletPath for synopsis"
        $Synopsis = ([regex]$SynopsisRegex).Matches($FormattedCommentBlock).Value

        If([String]::IsNullOrEmpty($Synopsis) -eq $true)
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] No synopsis found"
                $Synopsis = ""
            }
        Else
            {
                $Synopsis = Format-TabbedString -String $Synopsis

                $Synopsis = $Synopsis -replace "(^\s{1})","" #Remove preceeding new line chars
                $Synopsis = $Synopsis -replace "(^\s{1})","" #Remove preceeding new line chars
                $Synopsis = $Synopsis -replace "(\s{1}$)","" #Remove following new line chars
            }

        $Object = [pscustomobject]@{
            Synopsis = $Synopsis
        }

        Return $Object
    }