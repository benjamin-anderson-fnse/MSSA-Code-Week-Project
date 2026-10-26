# MSSA-Code-Week-Project

This repository highlights personal code projects utilizing PowerShell.

## Projects

### System inventory

`projects/SystemInventory/Get-SystemInventory.ps1` collects a local Windows
computer's operating system, hardware, disk, and enabled network adapter
details.

Run it from PowerShell to print JSON to the console:

```powershell
.\projects\SystemInventory\Get-SystemInventory.ps1
```

Save the inventory to a JSON file:

```powershell
.\projects\SystemInventory\Get-SystemInventory.ps1 `
    -OutputPath .\output\system-inventory.json
```
