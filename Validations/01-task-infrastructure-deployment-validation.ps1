using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-$DID"
$count = 0
$found = $false

function Test-LabDeployment {
    param(
        [string]$ResourceGroupName
    )

    $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -ErrorAction Stop |
        Sort-Object Timestamp -Descending |
        Select-Object -First 1

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -ErrorAction Stop | Select-Object -First 1
    $subnet = $null
    if ($null -ne $vnet) {
        $subnet = $vnet.Subnets | Select-Object -First 1
    }

    $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -ErrorAction Stop | Select-Object -First 1
    $windowsVm = Get-AzVM -ResourceGroupName $ResourceGroupName -Status -ErrorAction Stop |
        Where-Object { $_.StorageProfile.OsDisk.OsType -eq 'Windows' } |
        Select-Object -First 1

    if ($null -ne $deployment -and $null -ne $vnet -and $null -ne $subnet -and $null -ne $nsg -and $null -ne $windowsVm) {
        return @{
            IsValid = $true
            Detail  = "Deployment '$($deployment.DeploymentName)' in RG '$ResourceGroupName' created VNet '$($vnet.Name)', subnet '$($subnet.Name)', NSG '$($nsg.Name)', and Windows VM '$($windowsVm.Name)'."
        }
    }

    $missing = @()
    if ($null -eq $deployment) { $missing += 'resource group deployment' }
    if ($null -eq $vnet) { $missing += 'virtual network' }
    if ($null -eq $subnet) { $missing += 'subnet' }
    if ($null -eq $nsg) { $missing += 'network security group' }
    if ($null -eq $windowsVm) { $missing += 'Windows VM' }

    return @{
        IsValid = $false
        Detail  = "Base ARM infrastructure check failed in RG '$ResourceGroupName'. Missing: $($missing -join ', ')."
    }
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $result = Test-LabDeployment -ResourceGroupName $rg
        if ($result.IsValid) {
            $found = $true
            $message = @{
                Status  = "Succeeded"
                Message = $result.Detail
            } | ConvertTo-Json
        } else {
            $message = @{
                Status  = "Failed"
                Message = $result.Detail
            } | ConvertTo-Json
        }

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })

        if (-not $found) {
            Start-Sleep -Seconds 10
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
        Message = "Base ARM infrastructure resources were not found in RG '$rg' after 3 attempts. Expected a resource group deployment, VNet, subnet, NSG, and Windows VM."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
