[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^[A-Za-z]$')]
    [string] $DriveName = 'C',

    [Parameter()]
    [ValidateRange(1, 100000)]
    [int] $MinimumFreeSpaceGB = 100,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $LogPath = (Join-Path $PSScriptRoot 'free-space.log')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $drive = Get-PSDrive -Name $DriveName -PSProvider FileSystem -ErrorAction Stop
    $threshold = $MinimumFreeSpaceGB * 1GB
    $freeSpaceBytes = [int64] $drive.Free
    $freeSpaceGB = [math]::Round($freeSpaceBytes / 1GB, 2)

    if ($freeSpaceBytes -lt $threshold) {
        $message = "WARNING: Free space on $DriveName`: is below $MinimumFreeSpaceGB GB. Current free space = $freeSpaceGB GB"
    }
    else {
        $message = "Free space on $DriveName`: is sufficient = $freeSpaceGB GB"
    }

    $timestampedMessage = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    $logDirectory = Split-Path -Parent $LogPath
    if ($logDirectory -and -not (Test-Path -LiteralPath $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    Add-Content -LiteralPath $LogPath -Value $timestampedMessage
    Write-Host $message
}
catch {
    $errorMessage = "{0} ERROR: Unable to check free space on $DriveName`:. {1}" -f `
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $_.Exception.Message
    Add-Content -LiteralPath $LogPath -Value $errorMessage
    Write-Error $errorMessage
    exit 1
}
