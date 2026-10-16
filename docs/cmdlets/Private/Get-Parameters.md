## Get-Parameters

### Description

Extracts parameter information from a PowerShell function script file, including both static and dynamic parameters.

---

```
Get-Parameters

	[-CmdletPath <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-Parameters.ps1](../../Private/Get-Parameters.ps1)

### Examples

#### Example 1
```powershell
Get-Parameters -CmdletPath C:\Path\To\Your\Cmdlet.ps1
```

---

### Parameters

#### -CmdletPath

The file path to the PowerShell function script file to extract parameters from.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
