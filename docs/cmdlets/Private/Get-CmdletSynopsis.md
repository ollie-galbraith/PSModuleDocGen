## Get-CmdletSynopsis

### Description



---

```
Get-CmdletSynopsis

	[-CmdletPath <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-CmdletSynopsis.ps1](../../Private/Get-CmdletSynopsis.ps1)

### Examples

#### Example 1
```powershell
Get-CmdletSynopsis -CmdletPath "C:\Users\ogalbraith\Desktop\Powershell\Modules\PSModuleDocGen\Format-MarkdownTable.ps1"
```

---

### Parameters

#### -CmdletPath

The file path to the PowerShell function script file to extract the synopsis from.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
