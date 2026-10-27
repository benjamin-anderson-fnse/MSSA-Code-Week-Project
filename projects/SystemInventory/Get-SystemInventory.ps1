[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-InventoryData {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $processor = Get-CimInstance -ClassName Win32_Processor |
        Select-Object -First 1

    $disks = @(
        Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
            ForEach-Object {
                [pscustomobject]@{
                    Drive       = $_.DeviceID
                    FileSystem  = $_.FileSystem
                    SizeGB      = [math]::Round($_.Size / 1GB, 2)
                    FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)
                }
            }
    )

    $networkAdapters = @(
        Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" |
            ForEach-Object {
                [pscustomobject]@{
                    Description = $_.Description
                    MacAddress  = $_.MACAddress
                    IPAddresses = @($_.IPAddress)
                    Gateways    = @($_.DefaultIPGateway)
                    DnsServers  = @($_.DNSServerSearchOrder)
                }
            }
    )

    [pscustomobject]@{
        CollectedAt = (Get-Date).ToUniversalTime().ToString('o')
        Computer    = [pscustomobject]@{
            Name           = $computerSystem.Name
            Manufacturer   = $computerSystem.Manufacturer
            Model          = $computerSystem.Model
            UserName       = $computerSystem.UserName
            SystemType     = $computerSystem.SystemType
            TotalMemoryGB  = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        }
        OperatingSystem = [pscustomobject]@{
            Caption       = $operatingSystem.Caption
            Version       = $operatingSystem.Version
            BuildNumber   = $operatingSystem.BuildNumber
            Architecture  = $operatingSystem.OSArchitecture
            LastBoot      = $operatingSystem.LastBootUpTime
        }
        Processor = [pscustomobject]@{
            Name                = $processor.Name
            Cores               = $processor.NumberOfCores
            LogicalProcessors  = $processor.NumberOfLogicalProcessors
            MaxClockSpeedMHz   = $processor.MaxClockSpeed
        }
        Disks          = $disks
        NetworkAdapters = $networkAdapters
    }
}

try {
    $inventory = Get-InventoryData

    if ($OutputPath) {
        $parent = Split-Path -Parent $OutputPath
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        $inventory | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputPath -Encoding utf8
        Write-Output "Inventory saved to $OutputPath"
    }
    else {
        $inventory | ConvertTo-Json -Depth 6
    }
}
catch {
    Write-Error "Unable to collect system inventory: $($_.Exception.Message)"
    exit 1
}
