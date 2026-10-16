Class CmdletOverall
    {
        $Name
        $Parameters
    }

Class CmdletParameters
    {
        $Name
        $Type
        $Options
        $DefaultValue
        $ValidateSet
        $ValidateRange
        $ValidatePattern
        $ValidateScript
    }

Class ParameterOptions
    {
        $Name
        $Value
    }

Class ParameterValidateSet
    {
        $ValidateSet
    }
Class ParameterValidateRange
    {
        $ValidateRange
    }
Class ParameterValidatePattern
    {
        $ValidatePattern
    }
Class ParameterValidateScript
    {
        $ValidateScript
    }


Get-ChildItem -Path $PSScriptRoot -Include *.ps1 -Recurse | Foreach-Object { . $_.FullName }
$ExportedFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\" | ForEach-Object {$_.Name -replace ".ps1"}
Export-ModuleMember -Function $ExportedFunctions