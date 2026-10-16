Function Format-TabbedString
    {
        <#
        .SYNOPSIS
        Formats a string with tabs for better readability by removing the smallest number of leading tabs from each line.
        .EXAMPLE
        Format-TabbedString -String $String
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, Position = 1, HelpMessage="The string with tabs to format for better readability by removing the smallest number of leading tabs from each line.")]
            [string]$String
        )

        $String = $String.TrimEnd(" ")
        $String = $String.TrimStart("`r`n")
        $String = $String.TrimEnd("`r`n")
        $SplitString = $String -split "`r`n"

        # If initial split with "<carriage return><new line>" didnt return more than 1 line
        If($SplitString.Count -eq 1)
            {
                # Split with just <new line>
                $SplitString = $String -split "`n"
            }

        $SpaceRegex = '^ *'

        $Index = 1
        Write-Verbose "$($SplitString.Count) lines found"
        $SmallestTabCount = [int]::MaxValue
        ForEach($Line in $SplitString)
            {
                If($Line -match "\S")
                    {
                        $SpaceCount = (([regex]$SpaceRegex).Matches($Line).Value).Length
                        $TabCount = $SpaceCount / 4
                        Write-Verbose "Line $Index has $TabCount tabs at the start"

                        If($TabCount -lt $SmallestTabCount)
                            {
                                $SmallestTabCount = $TabCount
                            }
                    }
                $Index += 1
            }

        Write-Verbose "Need to move left by $SmallestTabCount tabs"
        $FormattedString = ''
        $RemoveTabsRegex = "^(\s{4}){$SmallestTabCount}"
        ForEach($Line in $SplitString)
            {
                $FormattedString += "$Line`r`n" -replace $RemoveTabsRegex, ''
            }

        Return $FormattedString
    }