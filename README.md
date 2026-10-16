### PSModuleDocGen

##### Description

PSModuleDocGen generates Markdown documentation for PowerShell modules and functions. It extracts comment-based help and parameter metadata, including types, defaults, parameter sets, validation attributes, and dynamic parameters. Generate per-function pages with synopsis, examples, source links, and parameter reference tables, then refresh a module README and documentation index for its public and private functions. Includes helpers for formatting Markdown tables and indented text.
*****

##### Available Cmdlets
+ [Format-MarkdownTable](docs/cmdlets/Format-MarkdownTable.md)
+ [Format-TabbedString](docs/cmdlets/Format-TabbedString.md)
+ [New-FunctionMarkdownDoc](docs/cmdlets/New-FunctionMarkdownDoc.md)
+ [Update-ModuleDocumentation](docs/cmdlets/Update-ModuleDocumentation.md)

##### Private Functions
+ [Export-ParameterBlock](docs/cmdlets/Private/Export-ParameterBlock.md)
+ [Get-CmdletExample](docs/cmdlets/Private/Get-CmdletExample.md)
+ [Get-CmdletSynopsis](docs/cmdlets/Private/Get-CmdletSynopsis.md)
+ [Get-Parameters](docs/cmdlets/Private/Get-Parameters.md)

*****

##### Usage
To install and use this module, use the following code

```powershell
PS C:\> Install-Module -Name PSModuleDocGen

PS C:\> Import-Module -Name PSModuleDocGen
```
