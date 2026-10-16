## Export-ParameterBlock

### Description

Exports all the parameters and their options for each cmdlet in a specified module

---

```
Export-ParameterBlock

	[-CmdletPath  <System.String[ ]>]
	[-Format     <System.Boolean[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Export-ParameterBlock.ps1](../../Private/Export-ParameterBlock.ps1)

### Examples

#### Example 1
```powershell
Export-ParameterBlock -CmdletPath <Path to cmdlet> -Format $true
```

---

### Parameters

#### -CmdletPath

The file path to the module to extract parameters from.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |


#### -Format

Indicates whether to format the output.

|              |                |
| ------------ | -------------- |
| Type         | System.Boolean |
| Mandatory    | False          |
| DefaultValue | $true          |
