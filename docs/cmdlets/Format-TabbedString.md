## Format-TabbedString

### Description

Formats a string with tabs for better readability by removing the smallest number of leading tabs from each line.

---

```
Format-TabbedString

	[-String <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Format-TabbedString.ps1](../Public/Format-TabbedString.ps1)

### Examples

#### Example 1
```powershell
Format-TabbedString -String $String
```

---

### Parameters

#### -String

The string with tabs to format for better readability by removing the smallest number of leading tabs from each line.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
