Function Get-CmdletExample
    {
        <#
        .SYNOPSIS
        Extracts the examples from a PowerShell function script file.
        .EXAMPLE
        Get-CmdletExample -CmdletPath <Path to cmdlet>
        #>

        param(
            [Parameter(Mandatory=$true, Position=0, HelpMessage="The file path to the PowerShell function script file to extract the examples from.")]
            [string]$CmdletPath
        )

        $ExampleRegex = '(?i)(?<=\.EXAMPLE)(.|\r|\n)+?(?=(\.EXAMPLE|#>))'
        [System.Collections.Arraylist]$Output = @()

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
                        Break
                    }
                $LineNumber += 1
            }

        $CommentBlock = $CmdletContent[$BlockStart..$BlockEnd]
        $JoinedCommentBlock = $CommentBlock -join "`r`n"

        If($null -ne $JoinedCommentBlock)
            {
                $Examples = ([regex]$ExampleRegex).Matches($JoinedCommentBlock).Value

                ForEach($Example in $Examples)
                    {
                        $Example = Format-TabbedString -String $Example

                        $Example = $Example -replace "(^\s{1})","" #Remove preceeding new line chars
                        $Example = $Example -replace "(\s{1}$)","" #Remove following new line chars
                        $Example = $Example -replace "($\s)","" #Remove new line chars after end of string

                        $Example = $Example -replace "\r\n",'__newline__' #Replace new line with new line char

                        $Object = [pscustomobject]@{
                            Example = $Example
                        }
                        [Void]$Output.Add($Object)
                    }

                If($Output.Count -ge 1)
                    {
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $($Output.Count) Examples found"
                    }
                Return $Output
            }
    }