[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $TaskName = 'Daily Free Space Check',

    [Parameter()]
    [ValidatePattern('^[A-Za-z]$')]
    [string] $DriveName = 'C',

    [Parameter()]
    [ValidateRange(1, 100000)]
    [int] $MinimumFreeSpaceGB = 100,

    [Parameter()]
    [ValidatePattern('^\d{2}:\d{2}$')]
    [string] $RunAt = '09:00'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$checkScriptPath = Join-Path $PSScriptRoot 'Check-FreeSpace.ps1'
if (-not (Test-Path -LiteralPath $checkScriptPath -PathType Leaf)) {
    throw "The monitoring script was not found at $checkScriptPath."
}

$powerShellPath = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
if (-not $powerShellPath) {
    $powerShellPath = (Get-Command pwsh.exe -ErrorAction Stop).Source
}
$arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -DriveName "{1}" -MinimumFreeSpaceGB {2}' -f `
    $checkScriptPath, $DriveName, $MinimumFreeSpaceGB

$action = New-ScheduledTaskAction -Execute $powerShellPath -Argument $arguments
$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::ParseExact($RunAt, 'HH:mm', $null))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Checks free space on drive $DriveName`: every day at $RunAt." `
    -Force | Out-Null

Write-Output "Registered '$TaskName' to run daily at $RunAt."
Write-Output "View it with: Get-ScheduledTask -TaskName '$TaskName'"
