Function Format-MarkDownTable
    {
        <#
        .SYNOPSIS
        Formats a Markdown table for better readability.
        .EXAMPLE
        Format-MarkDownTable -Table $Table
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position = 1, HelpMessage="The Markdown table string to format for better readability.")]
            [string]$Table,
            [Parameter(Mandatory=$false, Position = 2, HelpMessage="If specified, the formatted table will be copied to the clipboard.")]
            [switch]$Clipboard
        )

        If ($PSBoundParameters['Debug']) {$DebugPreference = 'Continue'}

        $Table = $Table.TrimStart("`r`n")
        $Table = $Table.TrimEnd("`r`n")
        $Rows = $Table -split "\r\n"
        If($Rows.Count -eq 1)
            {
                $Rows = $Table -split "\n"
            }

        $TableDelimiter = '(?<!\\)\|'

        ForEach($Row in $Rows)
            {
                If(($Rows.IndexOf($Row) + 1) -eq 2)
                    {
                        Continue
                    }

                $RowSplit = $Row -split $TableDelimiter
                $TotalColumns = ($RowSplit.Count - 2)

                $RowSplit = $RowSplit[1..$TotalColumns]

                $Column = 1

                While($Column -le $TotalColumns)
                    {
                        $CurrentColumn = $RowSplit[$Column - 1].Trim()

                        $Length = $CurrentColumn.Length
                        $VariableName = "Row$($Rows.IndexOf($Row) + 1)Column$Column"
                        New-Variable -Name $VariableName -Value $Length
                        Write-Debug "Row $($Rows.IndexOf($Row) + 1): Column $Column Length: $Length"

                        $Column += 1
                    }
            }

        $ColumnNumber = 1

        While($ColumnNumber -le $TotalColumns)
            {
                $RowNumber = 1
                $ColumnLength  = 0
                While($RowNumber -le $Rows.Count)
                    {
                        If($RowNumber -eq 2)
                            {
                                $RowNumber += 1
                                Continue
                            }
                        $TempColumnLength = Get-Variable -Name "Row$RowNumber`Column$ColumnNumber" -ValueOnly
                        If($TempColumnLength -gt $ColumnLength)
                            {
                                $ColumnLength = $TempColumnLength
                            }
                        $RowNumber += 1
                    }

                New-Variable -Name "Column$ColumnNumber`Length" -Value $ColumnLength

                Write-Debug "Column$ColumnNumber Length: $ColumnLength"
                $ColumnNumber += 1
            }

        $NewTable = ""
        ForEach($Row in $Rows)
            {
                $NewRow = '|'
                $RowSplit = $Row -split $TableDelimiter
                $TotalColumns = ($RowSplit.Count - 2)

                $RowSplit = $RowSplit[1..$TotalColumns]

                $ColumnNumber = 1

                $NewCharacters = " "
                If($Rows.IndexOf($Row) -eq 1)
                    {
                        $NewCharacters = '-'
                    }

                While($ColumnNumber -le $TotalColumns)
                    {
                        $ColumnLength = Get-Variable -Name "Column$ColumnNumber`Length" -ValueOnly

                        $CurrentValue = $RowSplit[$ColumnNumber - 1]
                        $AddedCharacters = $ColumnLength - ($CurrentValue.Trim()).Length

                        If($CurrentValue.Length -ge 1)
                            {
                                If($AddedCharacters -lt 0)
                                    {
                                        $NewTableValue = ($CurrentValue).Trim().Substring(0,(($CurrentValue.Trim()).Length - ($AddedCharacters * -1)))
                                        Write-Debug "Removing '$NewCharacters' * $($AddedCharacters * -1) from $(($CurrentValue).Trim())"
                                    }
                                Else
                                    {
                                        $NewTableValue = ($CurrentValue).Trim() + ($NewCharacters * $AddedCharacters)
                                        Write-Debug "Adding '$NewCharacters' * $AddedCharacters to $(($CurrentValue).Trim())"
                                    }
                                $NewRow += " $NewTableValue |"
                            }
                        Else
                            {
                                $NewTableValue = ($NewCharacters * $AddedCharacters)
                                $NewRow += " $NewTableValue `|"
                            }

                        $ColumnNumber += 1
                    }

                $NewTable += "$NewRow`r`n"
            }

        Get-Variable -Name Row* | Remove-Variable
        Get-Variable -Name Column* | Remove-Variable

        If($Clipboard -eq $true)
            {
                $NewTable | Set-Clipboard
            }

        Return $NewTable
    }