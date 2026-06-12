using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-$DID"
$count = 0
$found = $false

$targetVmNames = @(
    "ubuntu-vm",
    "windows-vm"
)

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $vmStatuses = @()

        foreach ($vmName in $targetVmNames) {
            $vm = Get-AzVM -ResourceGroupName $rg -Name $vmName -Status -ErrorAction SilentlyContinue
            if ($null -ne $vm) {
                $powerState = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -ExpandProperty DisplayStatus -First 1)
                $vmStatuses += [PSCustomObject]@{
                    Name       = $vmName
                    PowerState = $powerState
                }
            }
        }

        $runningVms = $vmStatuses | Where-Object { $_.PowerState -eq 'VM running' }

        if ($runningVms.Count -ge 1) {
            $found = $true
            $runningNames = ($runningVms | ForEach-Object { "$($_.Name) ($($_.PowerState))" }) -join ', '
            $message = @{
                Status  = "Succeeded"
                Message = "Azure VM automation end state validated in RG '$rg'. Running VM targets detected: $runningNames."
            } | ConvertTo-Json
        } else {
            $observed = if ($vmStatuses.Count -gt 0) {
                ($vmStatuses | ForEach-Object { "$($_.Name): $($_.PowerState)" }) -join '; '
            } else {
                'No targeted VMs were found.'
            }
            $message = @{
                Status  = "Failed"
                Message = "Azure VM automation validation failed in RG '$rg'. Expected at least one targeted VM in a started end state after stop/start operations. Observed: $observed"
            } | ConvertTo-Json
        }
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
    }
    catch {
        $message = @{
            Status  = "Failed"
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
        Status  = "Failed"
        Message = "Azure VM automation validation did not confirm the required started end state in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
