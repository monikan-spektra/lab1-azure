using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-lab1-azure-powershell-winlinux-$DID"
$count = 0
$found = $false

$windowsVmName = "win-vm01"
$ubuntuVmName = "ubuntu-vm01"

function Get-PowerState {
    param(
        [Parameter(Mandatory = $true)]
        $StatusObject
    )

    return ($StatusObject.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -First 1).DisplayStatus
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $windowsVm = Get-AzVM -ResourceGroupName $rg -Name $windowsVmName -Status -ErrorAction Stop
        $ubuntuVm = Get-AzVM -ResourceGroupName $rg -Name $ubuntuVmName -Status -ErrorAction Stop

        $windowsPowerState = Get-PowerState -StatusObject $windowsVm
        $ubuntuPowerState = Get-PowerState -StatusObject $ubuntuVm

        if ($windowsPowerState -eq 'VM running' -and $ubuntuPowerState -eq 'VM running') {
            $found = $true
            $message = @{
                Status  = 'Succeeded'
                Message = "Azure VM automation validation passed. Windows VM '$windowsVmName' and Ubuntu VM '$ubuntuVmName' are both in the required final power state 'VM running' in resource group '$rg'."
            } | ConvertTo-Json
        }
        else {
            $message = @{
                Status  = 'Failed'
                Message = "Azure VM automation validation failed. Expected both VMs to finish in power state 'VM running' after stop/start automation. Current states in resource group '$rg': Windows VM '$windowsVmName' = '$windowsPowerState'; Ubuntu VM '$ubuntuVmName' = '$ubuntuPowerState'."
            } | ConvertTo-Json
        }

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
    }
    catch {
        $message = @{
            Status  = 'Failed'
            Message = "Error during check. Attempt $count of 3. Error: $($_.Exception.Message)"
        } | ConvertTo-Json
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
        Start-Sleep -Seconds 10
    }
} while ($count -lt 3 -and -not $found)

# Post-loop: if every attempt failed, emit a final failure JSON so CloudLabs
# always sees a structured result.
if (-not $found) {
    $message = @{
        Status  = 'Failed'
        Message = "Azure VM automation validation did not reach the required end state. Windows VM '$windowsVmName' and Ubuntu VM '$ubuntuVmName' were not both found in power state 'VM running' in resource group '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
