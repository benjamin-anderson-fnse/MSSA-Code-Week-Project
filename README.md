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

### Daily free-space monitor

`projects/FreeSpaceMonitor/Check-FreeSpace.ps1` checks the free space on the
`C:` drive and appends the result to `free-space.log`. Register it with
Windows Task Scheduler to run every day at 9:00 AM:

```powershell
.\projects\FreeSpaceMonitor\Register-FreeSpaceTask.ps1
```

The registration is safe to run again because it updates the existing task.
Customize the drive, threshold, or time as needed:

```powershell
.\projects\FreeSpaceMonitor\Register-FreeSpaceTask.ps1 `
    -DriveName D `
    -MinimumFreeSpaceGB 50 `
    -RunAt 09:00
```

Run the check immediately without waiting for the scheduled trigger:

```powershell
.\projects\FreeSpaceMonitor\Check-FreeSpace.ps1
```
