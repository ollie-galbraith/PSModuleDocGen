## Update-ModuleDocumentation

### Description

This function updates the documentation for a specified PowerShell module. It can use either the module's path or name to locate the module and generate the documentation.

---

```
Update-ModuleDocumentation

	[-Path         <System.String[ ]>]
	[-Description  <System.String[ ]>]
	[-ShowOutput  <System.Boolean[ ]>]
	[<CommonParameters>]


Update-ModuleDocumentation

	[-Name                <String[ ]>]
	[-Description  <System.String[ ]>]
	[-ShowOutput  <System.Boolean[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Update-ModuleDocumentation.ps1](../Public/Update-ModuleDocumentation.ps1)

### Examples

#### Example 1
```powershell
# Update documentation for a module using the module path
Update-ModuleDocumentation -Path "C:\Users\ogalbraith\Documents\WindowsPowerShell\Modules\PSModuleDocGen"
```
#### Example 2
```powershell
# Update documentation for a module using the module name
Update-ModuleDocumentation -Name "PSModuleDocGen"
```

---

### Parameters

#### -Description

The description of the module

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -Name

The name of the module to document. This will be used to find the module path. This parameter is not required if the ModulePath parameter is used.

|                   |            |
| ----------------- | ---------- |
| Type              | String     |
| Mandatory         | True       |
| ParameterSetNames | ModuleName |


#### -Path

The file path to the module to document

|                   |               |
| ----------------- | ------------- |
| Type              | System.String |
| Mandatory         | True          |
| ParameterSetNames | ModulePath    |


#### -ShowOutput

Show the output of the documentation generation process in the console

|              |                |
| ------------ | -------------- |
| Type         | System.Boolean |
| Mandatory    | False          |
| DefaultValue | $False         |
