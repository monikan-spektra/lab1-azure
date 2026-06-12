using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-lab1-$DID"
$count = 0
$found = $false

function Get-RunningLinuxVm {
    param(
        [string]$ResourceGroupName
    )

    $vms = Get-AzVM -ResourceGroupName $ResourceGroupName -Status -ErrorAction Stop
    foreach ($vm in $vms) {
        if ($vm.StorageProfile.OSDisk.OsType -eq 'Linux') {
            $powerState = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -First 1).DisplayStatus
            if ($powerState -eq 'VM running') {
                return $vm
            }
        }
    }

    return $null
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop | Out-Null

        $vm = Get-RunningLinuxVm -ResourceGroupName $rg
        if ($null -ne $vm) {
            $nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id
            $nic = Get-AzNetworkInterface -ResourceId $nicId -ErrorAction Stop
            $pipId = $nic.IpConfigurations[0].PublicIpAddress.Id

            if ($pipId) {
                $pip = Get-AzPublicIpAddress -ResourceId $pipId -ErrorAction Stop
                $ipAddress = $pip.IpAddress

                if (-not [string]::IsNullOrWhiteSpace($ipAddress)) {
                    $response = Invoke-WebRequest -Uri ("http://{0}" -f $ipAddress) -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
                    $statusOk = $response.StatusCode -eq 200
                    $contentOk = $response.Content -match 'Apache2 Ubuntu Default Page|It works|Apache'

                    if ($statusOk -and $contentOk) {
                        $found = $true
                        $message = @{
                            Status  = "Succeeded"
                            Message = "Apache is installed and responding on Ubuntu VM '$($vm.Name)' in RG '$rg'. HTTP port 80 is reachable at $ipAddress and returned a successful web response."
                        } | ConvertTo-Json
                    }
                }
            }
        }

        if ($found) {
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [HttpStatusCode]::OK
                Body       = $message
            })
        } else {
            $message = @{
                Status  = "Failed"
                Message = "Could not confirm the Ubuntu Apache web server in RG '$rg'. Ensure the Ubuntu VM is running, has a public IP, Apache is installed and running, and HTTP port 80 is reachable and responding."
            } | ConvertTo-Json
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [HttpStatusCode]::OK
                Body       = $message
            })
        }
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

if (-not $found) {
    $message = @{
        Status  = "Failed"
        Message = "Apache web server validation did not succeed in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
