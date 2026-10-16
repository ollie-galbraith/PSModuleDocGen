## New-FunctionMarkdownDoc

### Description

Generates markdown documentation for a PowerShell function script.

---

```
New-FunctionMarkdownDoc

	[-FunctionPath                                <System.String[ ]>]
	[-OutputPath                                  <System.String[ ]>]
	[-Output       <System.Management.Automation.SwitchParameter[ ]>]
	[-ShowOutput                                 <System.Boolean[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[New-FunctionMarkdownDoc.ps1](../Public/New-FunctionMarkdownDoc.ps1)

### Examples

#### Example 1
```powershell
New-FunctionMarkdownDoc -FunctionPath 'C:\Users\ogalbraith\Documents\WindowsPowerShell\Modules\PSModuleDocGen\Public\Get-Parameters.ps1'
```

---

### Parameters

#### -FunctionPath

The file path to the PowerShell function file.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |


#### -Output

Output the generated markdown content to the console instead of writing to a file

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -OutputPath

The file path to output the generated markdown documentation to. If not specified, the markdown file will be created in the same directory as the function file with the same name and a .md extension.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -ShowOutput

Show the output of the documentation generation process in the console

|              |                |
| ------------ | -------------- |
| Type         | System.Boolean |
| Mandatory    | False          |
| DefaultValue | $False         |
