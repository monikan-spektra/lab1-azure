Param (
    [string]
    $DeploymentID,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword
)

# =====================================================================
# CloudLabs CSE bootstrap - Nedbank VDI Platform Intermediate assessment
# Seeds a "morning health check after a patch window" scenario for a
# Nutanix HCI cluster + Citrix site on the CloudLabs Windows JumpVM.
# The Nutanix and Citrix control planes are SIMULATED: JSON snapshot
# state under C:\Nedbank\VDI plus two mock PowerShell modules
# (NedNutanix, NedCitrix) whose cmdlets read and write that state.
# Invoked by the ARM CustomScriptExtension:
#   powershell -ExecutionPolicy Unrestricted -File psscript-01.ps1 `
#     -DeploymentID <id> -trainerUserName <user> -trainerUserPassword <pass>
# Idempotent-ish: safe to re-run (state files are only seeded if absent).
# =====================================================================
Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

New-Item -ItemType Directory -Path C:\LabFiles -Force | Out-Null
@"
DeploymentID: $DeploymentID
TrainerUser: $trainerUserName
"@ | Set-Content -Path C:\LabFiles\AzureCreds.txt

New-Item -ItemType Directory -Path C:\Nedbank\VDI     -Force | Out-Null
New-Item -ItemType Directory -Path C:\Nedbank\Reports -Force | Out-Null
New-Item -ItemType Directory -Path C:\Nedbank\Scripts -Force | Out-Null

# ---------------------------------------------------------------------
# SEED STATE 1 - Nutanix cluster snapshot (4 hosts, 32 pCPU cores each).
# SEED FAULT 1: during the patch window NTNX-HOST-02 was drained and its
# VMs were migrated onto NTNX-HOST-03 - they were never rebalanced.
# NTNX-HOST-02 is back online (maintenance mode cleared) but EMPTY,
# while NTNX-HOST-03 carries 152 vCPU on 32 pCPU cores (4.75:1 ratio,
# above the Nedbank 4:1 ceiling). The candidate must move the two
# payments VDI VMs (NEDVDI-PAY-201, NEDVDI-PAY-202) to NTNX-HOST-02.
# ---------------------------------------------------------------------
if (-not (Test-Path "C:\Nedbank\VDI\cluster.json")) {
@'
{
  "name": "NBK-HCI-PROD-01",
  "uuid": "0005a1b2-7c44-49e1-b3aa-2f1c9e6d8a01",
  "aosVersion": "6.8.1",
  "redundancyFactor": 2,
  "hypervisor": "AHV",
  "numHosts": 4,
  "dataResiliencyStatus": "OK",
  "lastPatchWindow": "2026-06-10T22:00:00Z"
}
'@ | Set-Content -Path "C:\Nedbank\VDI\cluster.json" -Encoding Ascii
}

if (-not (Test-Path "C:\Nedbank\VDI\hosts.json")) {
@'
[
  {
    "name": "NTNX-HOST-01",
    "serial": "NX-8035-G8-1001",
    "state": "NORMAL",
    "maintenanceMode": false,
    "pCpuCores": 32,
    "memoryGiB": 512,
    "cvmIp": "10.20.30.11",
    "notes": "Patched 2026-06-10, VMs untouched"
  },
  {
    "name": "NTNX-HOST-02",
    "serial": "NX-8035-G8-1002",
    "state": "NORMAL",
    "maintenanceMode": false,
    "pCpuCores": 32,
    "memoryGiB": 512,
    "cvmIp": "10.20.30.12",
    "notes": "Drained for patching 2026-06-10, returned to service empty"
  },
  {
    "name": "NTNX-HOST-03",
    "serial": "NX-8035-G8-1003",
    "state": "NORMAL",
    "maintenanceMode": false,
    "pCpuCores": 32,
    "memoryGiB": 512,
    "cvmIp": "10.20.30.13",
    "notes": "Received the VMs evacuated from NTNX-HOST-02"
  },
  {
    "name": "NTNX-HOST-04",
    "serial": "NX-8035-G8-1004",
    "state": "NORMAL",
    "maintenanceMode": false,
    "pCpuCores": 32,
    "memoryGiB": 512,
    "cvmIp": "10.20.30.14",
    "notes": "Patched 2026-06-10, VMs untouched"
  }
]
'@ | Set-Content -Path "C:\Nedbank\VDI\hosts.json" -Encoding Ascii
}

if (-not (Test-Path "C:\Nedbank\VDI\vms.json")) {
@'
[
  { "name": "NEDVDI-CTX-001", "uuid": "b1f1aa01-1111-4a01-9c01-000000000001", "host": "NTNX-HOST-01", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-002", "uuid": "b1f1aa01-1111-4a01-9c01-000000000002", "host": "NTNX-HOST-01", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-003", "uuid": "b1f1aa01-1111-4a01-9c01-000000000003", "host": "NTNX-HOST-01", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-MGT-001", "uuid": "b1f1aa01-1111-4a01-9c01-000000000004", "host": "NTNX-HOST-01", "vCpu": 16, "memoryGiB": 48, "powerState": "ON", "role": "Citrix Delivery Controller" },
  { "name": "NEDVDI-CTX-101", "uuid": "b1f1aa01-1111-4a01-9c01-000000000101", "host": "NTNX-HOST-03", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-102", "uuid": "b1f1aa01-1111-4a01-9c01-000000000102", "host": "NTNX-HOST-03", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-103", "uuid": "b1f1aa01-1111-4a01-9c01-000000000103", "host": "NTNX-HOST-03", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-104", "uuid": "b1f1aa01-1111-4a01-9c01-000000000104", "host": "NTNX-HOST-03", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-105", "uuid": "b1f1aa01-1111-4a01-9c01-000000000105", "host": "NTNX-HOST-03", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-106", "uuid": "b1f1aa01-1111-4a01-9c01-000000000106", "host": "NTNX-HOST-03", "vCpu": 24, "memoryGiB": 96, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-PAY-201", "uuid": "b1f1aa01-1111-4a01-9c01-000000000201", "host": "NTNX-HOST-03", "vCpu": 24, "memoryGiB": 96, "powerState": "ON", "role": "Payments teller VDI pool" },
  { "name": "NEDVDI-PAY-202", "uuid": "b1f1aa01-1111-4a01-9c01-000000000202", "host": "NTNX-HOST-03", "vCpu": 24, "memoryGiB": 96, "powerState": "ON", "role": "Payments teller VDI pool" },
  { "name": "NEDVDI-CTX-301", "uuid": "b1f1aa01-1111-4a01-9c01-000000000301", "host": "NTNX-HOST-04", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-302", "uuid": "b1f1aa01-1111-4a01-9c01-000000000302", "host": "NTNX-HOST-04", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-303", "uuid": "b1f1aa01-1111-4a01-9c01-000000000303", "host": "NTNX-HOST-04", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-CTX-304", "uuid": "b1f1aa01-1111-4a01-9c01-000000000304", "host": "NTNX-HOST-04", "vCpu": 16, "memoryGiB": 64, "powerState": "ON", "role": "Citrix multi-session worker" },
  { "name": "NEDVDI-MGT-002", "uuid": "b1f1aa01-1111-4a01-9c01-000000000305", "host": "NTNX-HOST-04", "vCpu": 16, "memoryGiB": 48, "powerState": "ON", "role": "Citrix StoreFront" }
]
'@ | Set-Content -Path "C:\Nedbank\VDI\vms.json" -Encoding Ascii
}

# ---------------------------------------------------------------------
# SEED STATE 2 - Citrix site snapshot (12 machines, 1 delivery group).
# SEED FAULT 2: after patching, 3 machines were left in maintenance
# mode (NBKVDI-W10-003, NBKVDI-W10-007, NBKVDI-W10-011) and 2 machines
# failed to re-register with the Delivery Controller (NBKVDI-W10-005,
# NBKVDI-W10-009). Branch users cannot get sessions. The candidate must
# clear maintenance mode and restore registration via Set-NbrokerMachine.
# ---------------------------------------------------------------------
if (-not (Test-Path "C:\Nedbank\VDI\citrix-site.json")) {
@'
{
  "name": "NBK-VDI-Site",
  "version": "2402 LTSR",
  "deliveryControllers": ["NEDVDI-MGT-001"],
  "deliveryGroups": [
    {
      "name": "NBK-Win10-Production",
      "machineCount": 12,
      "provisioningType": "MCS",
      "sessionSupport": "SingleSession"
    }
  ],
  "licenseServer": "nbk-ctxlic-01.nedbank.local"
}
'@ | Set-Content -Path "C:\Nedbank\VDI\citrix-site.json" -Encoding Ascii
}

if (-not (Test-Path "C:\Nedbank\VDI\citrix-machines.json")) {
@'
[
  { "machineName": "NBKVDI-W10-001", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-002", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-003", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": true, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-004", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-005", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Unregistered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-006", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-007", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": true, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-008", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-009", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Unregistered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-010", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-011", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": true, "powerState": "On", "agentVersion": "2402.0.100" },
  { "machineName": "NBKVDI-W10-012", "deliveryGroup": "NBK-Win10-Production", "registrationState": "Registered", "inMaintenanceMode": false, "powerState": "On", "agentVersion": "2402.0.100" }
]
'@ | Set-Content -Path "C:\Nedbank\VDI\citrix-machines.json" -Encoding Ascii
}

if (-not (Test-Path "C:\Nedbank\VDI\citrix-sessions.json")) {
@'
[
  { "user": "NEDBANK\\thandi.mokoena", "machineName": "NBKVDI-W10-001", "sessionState": "Active", "protocol": "HDX", "startTime": "2026-06-11T06:42:00Z" },
  { "user": "NEDBANK\\pieter.vanwyk", "machineName": "NBKVDI-W10-002", "sessionState": "Active", "protocol": "HDX", "startTime": "2026-06-11T06:45:00Z" },
  { "user": "NEDBANK\\lerato.dube", "machineName": "NBKVDI-W10-004", "sessionState": "Active", "protocol": "HDX", "startTime": "2026-06-11T06:47:00Z" },
  { "user": "NEDBANK\\sipho.ndlovu", "machineName": "NBKVDI-W10-006", "sessionState": "Disconnected", "protocol": "HDX", "startTime": "2026-06-10T16:05:00Z" },
  { "user": "NEDBANK\\anita.naidoo", "machineName": "NBKVDI-W10-008", "sessionState": "Active", "protocol": "HDX", "startTime": "2026-06-11T06:51:00Z" },
  { "user": "NEDBANK\\johan.botha", "machineName": "NBKVDI-W10-010", "sessionState": "Active", "protocol": "HDX", "startTime": "2026-06-11T06:53:00Z" },
  { "user": "NEDBANK\\zanele.khumalo", "machineName": "NBKVDI-W10-012", "sessionState": "Disconnected", "protocol": "HDX", "startTime": "2026-06-10T15:31:00Z" }
]
'@ | Set-Content -Path "C:\Nedbank\VDI\citrix-sessions.json" -Encoding Ascii
}

# ---------------------------------------------------------------------
# Mock module 1 - NedNutanix (stands in for Nutanix Prism / cmdlets).
# Cmdlets read and write the JSON snapshot state under C:\Nedbank\VDI.
# ---------------------------------------------------------------------
$ntnxDir = "C:\Program Files\WindowsPowerShell\Modules\NedNutanix"
New-Item -ItemType Directory -Path $ntnxDir -Force | Out-Null

@'
# NedNutanix - mock Nutanix Prism cmdlets for the Nedbank VDI assessment.
# All cmdlets are backed by JSON snapshot state under C:\Nedbank\VDI.

$script:StateDir = "C:\Nedbank\VDI"

function Get-NtnxStatePath {
    param([string]$File)
    Join-Path $script:StateDir $File
}

function Get-NtnxCluster {
    [CmdletBinding()]
    param()
    Get-Content (Get-NtnxStatePath "cluster.json") -Raw | ConvertFrom-Json
}

function Get-NtnxHost {
    [CmdletBinding()]
    param([string]$Name)
    $hosts = Get-Content (Get-NtnxStatePath "hosts.json") -Raw | ConvertFrom-Json
    if ($PSBoundParameters.ContainsKey("Name")) {
        $hosts | Where-Object { $_.name -eq $Name }
    } else {
        $hosts
    }
}

function Get-NtnxVM {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$HostName
    )
    $vms = Get-Content (Get-NtnxStatePath "vms.json") -Raw | ConvertFrom-Json
    if ($PSBoundParameters.ContainsKey("Name"))     { $vms = @($vms | Where-Object { $_.name -eq $Name }) }
    if ($PSBoundParameters.ContainsKey("HostName")) { $vms = @($vms | Where-Object { $_.host -eq $HostName }) }
    $vms
}

function Move-NtnxVM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$DestinationHost
    )
    $vmsPath = Get-NtnxStatePath "vms.json"
    $vms = Get-Content $vmsPath -Raw | ConvertFrom-Json
    $vm = $vms | Where-Object { $_.name -eq $Name }
    if (-not $vm) { throw "VM '$Name' not found in cluster inventory." }
    $target = Get-NtnxHost -Name $DestinationHost
    if (-not $target) { throw "Host '$DestinationHost' not found in cluster inventory." }
    if ($target.maintenanceMode -eq $true) { throw "Host '$DestinationHost' is in maintenance mode and cannot receive VMs." }
    $vm.host = $DestinationHost
    ConvertTo-Json -InputObject @($vms) -Depth 6 | Set-Content -Path $vmsPath -Encoding Ascii
    Write-Output ("Live migration complete: VM '" + $Name + "' is now running on host '" + $DestinationHost + "'.")
}

function Set-NtnxVM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [ValidateSet("ON", "OFF")][string]$PowerState,
        [int]$VCpu
    )
    $vmsPath = Get-NtnxStatePath "vms.json"
    $vms = Get-Content $vmsPath -Raw | ConvertFrom-Json
    $vm = $vms | Where-Object { $_.name -eq $Name }
    if (-not $vm) { throw "VM '$Name' not found in cluster inventory." }
    if ($PSBoundParameters.ContainsKey("PowerState")) { $vm.powerState = $PowerState }
    if ($PSBoundParameters.ContainsKey("VCpu"))       { $vm.vCpu = $VCpu }
    ConvertTo-Json -InputObject @($vms) -Depth 6 | Set-Content -Path $vmsPath -Encoding Ascii
    Write-Output ("VM '" + $Name + "' updated.")
}

Export-ModuleMember -Function Get-NtnxCluster, Get-NtnxHost, Get-NtnxVM, Move-NtnxVM, Set-NtnxVM
'@ | Set-Content -Path "$ntnxDir\NedNutanix.psm1" -Encoding Ascii

@'
@{
    RootModule        = "NedNutanix.psm1"
    ModuleVersion     = "1.0.0"
    GUID              = "d4b83147-149b-485f-a029-6ce06d81b489"
    Author            = "Nedbank VDI Platform Team"
    CompanyName       = "Nedbank"
    Description       = "Mock Nutanix Prism cmdlets backed by JSON snapshot state (Nedbank VDI assessment)."
    PowerShellVersion = "5.1"
    FunctionsToExport = @("Get-NtnxCluster", "Get-NtnxHost", "Get-NtnxVM", "Move-NtnxVM", "Set-NtnxVM")
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
'@ | Set-Content -Path "$ntnxDir\NedNutanix.psd1" -Encoding Ascii

# ---------------------------------------------------------------------
# Mock module 2 - NedCitrix (stands in for the Citrix Broker SDK).
# ---------------------------------------------------------------------
$ctxDir = "C:\Program Files\WindowsPowerShell\Modules\NedCitrix"
New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null

@'
# NedCitrix - mock Citrix Broker SDK cmdlets for the Nedbank VDI assessment.
# All cmdlets are backed by JSON snapshot state under C:\Nedbank\VDI.

$script:StateDir = "C:\Nedbank\VDI"

function Get-NbrokerStatePath {
    param([string]$File)
    Join-Path $script:StateDir $File
}

function Get-NbrokerSite {
    [CmdletBinding()]
    param()
    Get-Content (Get-NbrokerStatePath "citrix-site.json") -Raw | ConvertFrom-Json
}

function Get-NbrokerMachine {
    [CmdletBinding()]
    param([string]$MachineName)
    $machines = Get-Content (Get-NbrokerStatePath "citrix-machines.json") -Raw | ConvertFrom-Json
    if ($PSBoundParameters.ContainsKey("MachineName")) {
        $machines | Where-Object { $_.machineName -eq $MachineName }
    } else {
        $machines
    }
}

function Get-NbrokerSession {
    [CmdletBinding()]
    param([string]$MachineName)
    $sessions = Get-Content (Get-NbrokerStatePath "citrix-sessions.json") -Raw | ConvertFrom-Json
    if ($PSBoundParameters.ContainsKey("MachineName")) {
        $sessions | Where-Object { $_.machineName -eq $MachineName }
    } else {
        $sessions
    }
}

function Set-NbrokerMachine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$MachineName,
        [bool]$InMaintenanceMode,
        [bool]$Registered
    )
    $machinesPath = Get-NbrokerStatePath "citrix-machines.json"
    $machines = Get-Content $machinesPath -Raw | ConvertFrom-Json
    $machine = $machines | Where-Object { $_.machineName -eq $MachineName }
    if (-not $machine) { throw "Machine '$MachineName' not found in the site." }
    if ($PSBoundParameters.ContainsKey("InMaintenanceMode")) {
        $machine.inMaintenanceMode = $InMaintenanceMode
    }
    if ($PSBoundParameters.ContainsKey("Registered")) {
        if ($Registered) {
            $machine.registrationState = "Registered"
        } else {
            $machine.registrationState = "Unregistered"
        }
    }
    ConvertTo-Json -InputObject @($machines) -Depth 6 | Set-Content -Path $machinesPath -Encoding Ascii
    Write-Output ("Machine '" + $MachineName + "' updated: registrationState=" + $machine.registrationState + ", inMaintenanceMode=" + $machine.inMaintenanceMode + ".")
}

Export-ModuleMember -Function Get-NbrokerSite, Get-NbrokerMachine, Get-NbrokerSession, Set-NbrokerMachine
'@ | Set-Content -Path "$ctxDir\NedCitrix.psm1" -Encoding Ascii

@'
@{
    RootModule        = "NedCitrix.psm1"
    ModuleVersion     = "1.0.0"
    GUID              = "3c7b25e9-d6d6-4112-a723-7f28535caacb"
    Author            = "Nedbank VDI Platform Team"
    CompanyName       = "Nedbank"
    Description       = "Mock Citrix Broker SDK cmdlets backed by JSON snapshot state (Nedbank VDI assessment)."
    PowerShellVersion = "5.1"
    FunctionsToExport = @("Get-NbrokerSite", "Get-NbrokerMachine", "Get-NbrokerSession", "Set-NbrokerMachine")
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
'@ | Set-Content -Path "$ctxDir\NedCitrix.psd1" -Encoding Ascii

# ---------------------------------------------------------------------
# AllUsers AllHosts profile - import both mock modules in every session.
# ---------------------------------------------------------------------
$profilePath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
$importBlock = @'
# Nedbank VDI assessment - auto-import mock platform modules
Import-Module NedNutanix -ErrorAction SilentlyContinue
Import-Module NedCitrix -ErrorAction SilentlyContinue
'@
if (-not (Test-Path $profilePath) -or -not ((Get-Content $profilePath -Raw -ErrorAction SilentlyContinue) -match "NedNutanix")) {
    Add-Content -Path $profilePath -Value $importBlock
}

# ---------------------------------------------------------------------
# Environment README for the candidate.
# ---------------------------------------------------------------------
@'
Nedbank VDI Platform assessment - environment reference
========================================================

Snapshot state (the simulated control plane) lives in C:\Nedbank\VDI:
  cluster.json           - Nutanix cluster summary (NBK-HCI-PROD-01, RF2, AHV)
  hosts.json             - 4 AHV hosts (name, pCpuCores, maintenanceMode, ...)
  vms.json               - VMs with vCpu counts and current host placement
  citrix-site.json       - Citrix site and delivery group summary
  citrix-machines.json   - 12 brokered machines (registration, maintenance mode)
  citrix-sessions.json   - current user sessions

Mock PowerShell modules (auto-imported in every session):
  NedNutanix : Get-NtnxCluster, Get-NtnxHost, Get-NtnxVM,
               Move-NtnxVM -Name <vm> -DestinationHost <host>,
               Set-NtnxVM -Name <vm> [-PowerState ON|OFF] [-VCpu <n>]
  NedCitrix  : Get-NbrokerSite, Get-NbrokerMachine [-MachineName <m>],
               Get-NbrokerSession [-MachineName <m>],
               Set-NbrokerMachine -MachineName <m> [-InMaintenanceMode <bool>] [-Registered <bool>]

The cmdlets read and write the JSON state files, exactly like Prism /
Broker SDK cmdlets would change the live platform. Write your reports to
C:\Nedbank\Reports and your scripts to C:\Nedbank\Scripts.

Nedbank capacity policy: the vCPU:pCPU ratio on any AHV host must not
exceed 4:1 for VDI workloads.
'@ | Set-Content -Path "C:\Nedbank\VDI\README.txt" -Encoding Ascii

Stop-Transcript
