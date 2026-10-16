@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSModuleDocGen.psm1'
    # Version number of this module.
    ModuleVersion = '1.0.5.7'
    # ID used to uniquely identify this module
    GUID = '317fa392-7c27-4330-b950-f9d3ab3b3e9a'
    # Author of this module
    Author = 'Oliver Galbraith'
    # Copyright statement for this module
    Copyright = '(c) 2026 Oliver Galbraith. All rights reserved.'
    # Description of the functionality provided by this module
    Description = 'PSModuleDocGen generates Markdown documentation for PowerShell modules and functions. It extracts comment-based help and parameter metadata, including types, defaults, parameter sets, validation attributes, and dynamic parameters. Generate per-function pages with synopsis, examples, source links, and parameter reference tables, then refresh a module README and documentation index for its public and private functions. Includes helpers for formatting Markdown tables and indented text.'
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('PSDynamicParameters')
    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('PSModuleDocGen.Format.ps1xml')
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    # Variables to export from this module
    VariablesToExport = '*'
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            #ExternalModuleDependencies = @()

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('PSModuleDocGen', 'Documentation', 'Module', 'Cmdlet', 'Function')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/ollie-galbraith/PSModuleDocGen'
        }
    }
}

