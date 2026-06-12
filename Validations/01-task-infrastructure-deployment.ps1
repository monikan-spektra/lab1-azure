using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-$DID"
$count = 0
$found = $false

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -ErrorAction SilentlyContinue | Select-Object -First 1
        $ubuntuVm = Get-AzVM -ResourceGroupName $rg -Status -ErrorAction SilentlyContinue | Where-Object {
            $_.StorageProfile.ImageReference.Offer -match 'Ubuntu'
        } | Select-Object -First 1
        $windowsVm = Get-AzVM -ResourceGroupName $rg -Status -ErrorAction SilentlyContinue | Where-Object {
            $_.StorageProfile.ImageReference.Offer -match 'Windows'
        } | Select-Object -First 1

        $subnetFound = $false
        if ($vnet -and $vnet.Subnets -and $vnet.Subnets.Count -ge 1) {
            $subnetFound = $true
        }

        if ($vnet -and $subnetFound -and $ubuntuVm -and $windowsVm) {
            $found = $true
            $message = @{
                Status  = "Succeeded"
                Message = "Infrastructure deployment validated in RG '$rg'. VNet '$($vnet.Name)' with subnet '$($vnet.Subnets[0].Name)', Ubuntu VM '$($ubuntuVm.Name)', and Windows VM '$($windowsVm.Name)' were found."
            } | ConvertTo-Json
        } else {
            $missing = @()
            if (-not $vnet) { $missing += 'virtual network' }
            if (-not $subnetFound) { $missing += 'subnet' }
            if (-not $ubuntuVm) { $missing += 'Ubuntu VM' }
            if (-not $windowsVm) { $missing += 'Windows VM' }

            $message = @{
                Status  = "Failed"
                Message = "Infrastructure deployment validation failed in RG '$rg'. Missing or undetected component(s): $($missing -join ', ')."
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
        Message = "Infrastructure deployment resources not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
