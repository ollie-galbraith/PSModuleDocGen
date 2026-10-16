## Format-MarkdownTable

### Description

Formats a Markdown table for better readability.

---

```
Format-MarkdownTable

	[-Table                                    <System.String[ ]>]
	[-Clipboard <System.Management.Automation.SwitchParameter[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Format-MarkdownTable.ps1](../Public/Format-MarkdownTable.ps1)

### Examples

#### Example 1
```powershell
Format-MarkDownTable -Table $Table
```

---

### Parameters

#### -Clipboard

If specified, the formatted table will be copied to the clipboard.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -Table

The Markdown table string to format for better readability.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
