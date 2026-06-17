Import-Module Az.Compute
Import-Module Az.Network
Import-Module Az.Resources
Import-Module Az.Accounts

$deployment_id     = $deployment_id
$resourceGroupName = "RG-01"
$sub_id            = $sub_id

Select-AzSubscription -SubscriptionId $sub_id | Out-Null

$stopRetry = $false
[int]$retryCount = 0
$maxRetries = 3

do {
    try {

        $validationSuccess = $true
        $failureReasons = @()

        $expectedNames = @(
            "lab-vnet",
            "lab-nsg",
            "ubuntuvm-$deployment_id",
            "ubuntuvm-$deployment_id-nic",
            "ubuntuvm-$deployment_id-pip",
            "ubuntuvm-$deployment_id-osdisk"
        )

        $rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

        if ($null -eq $rg) {
            $validationSuccess = $false
            $failureReasons += "Resource group '$resourceGroupName' does not exist."
        }

        if ($validationSuccess) {

            $resources = @(Get-AzResource -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue)

            foreach ($name in $expectedNames) {
                if ($name -notin $resources.Name) {
                    $validationSuccess = $false
                    $failureReasons += "'$name' was not found."
                }
            }

            $vnet = Get-AzVirtualNetwork `
                -ResourceGroupName $resourceGroupName `
                -Name "lab-vnet" `
                -ErrorAction SilentlyContinue

            if ($null -eq $vnet) {
                $validationSuccess = $false
                $failureReasons += "Virtual Network 'lab-vnet' was not found."
            }
            elseif ($vnet.Subnets.Count -ne 1) {
                $validationSuccess = $false
                $failureReasons += "The Virtual Network must contain exactly one subnet."
            }

            $nsg = Get-AzNetworkSecurityGroup `
                -ResourceGroupName $resourceGroupName `
                -Name "lab-nsg" `
                -ErrorAction SilentlyContinue

            if ($null -eq $nsg) {
                $validationSuccess = $false
                $failureReasons += "Network Security Group 'lab-nsg' was not found."
            }

            # Get VM object for OS validation
            $vm = Get-AzVM `
                -ResourceGroupName $resourceGroupName `
                -Name "ubuntuvm-$deployment_id" `
                -ErrorAction SilentlyContinue

            if ($null -eq $vm) {
                $validationSuccess = $false
                $failureReasons += "Virtual Machine 'ubuntuvm-$deployment_id' was not found."
            }
            else {

                if ($vm.Name -ne "ubuntuvm-$deployment_id") {
                    $validationSuccess = $false
                    $failureReasons += "The Virtual Machine name must be 'ubuntuvm-$deployment_id'."
                }

                if ($vm.StorageProfile.OSDisk.OsType.ToString() -ne "Linux") {
                    $validationSuccess = $false
                    $failureReasons += "The Virtual Machine must be a Linux VM."
                }

                # Get VM status separately for provisioning state validation
                $vmStatus = Get-AzVM `
                    -ResourceGroupName $resourceGroupName `
                    -Name "ubuntuvm-$deployment_id" `
                    -Status `
                    -ErrorAction SilentlyContinue

                $provisioningStatus = $vmStatus.Statuses | Where-Object {
                    $_.Code -like "ProvisioningState/*"
                }

                if ($null -eq $provisioningStatus -or $provisioningStatus.DisplayStatus -notmatch "succeeded") {
                    $validationSuccess = $false
                    $failureReasons += "The Virtual Machine provisioning state must be Succeeded."
                }
            }
        }

        if ($validationSuccess) {

            $message = @{
                Status  = "Succeeded"
                Message = "Validation Success. Required resources were deployed successfully: lab-vnet, lab-nsg, ubuntuvm-$deployment_id, ubuntuvm-$deployment_id-nic, ubuntuvm-$deployment_id-pip and ubuntuvm-$deployment_id-osdisk."
            } | ConvertTo-Json -Compress
        }
        else {

            $message = @{
                Status  = "Failed"
                Message = ($failureReasons -join " ")
            } | ConvertTo-Json -Compress
        }

        Push-OutputBinding -Name Response -Value (
            [HttpResponseContext]@{
                StatusCode = [System.Net.HttpStatusCode]::OK
                Body       = $message
            }
        )

        $stopRetry = $true
    }
    catch {

        if ($retryCount -ge $maxRetries) {

            Push-OutputBinding -Name Response -Value (
                [HttpResponseContext]@{
                    StatusCode = [System.Net.HttpStatusCode]::OK
                    Body = (
                        @{
                            Status  = "Failed"
                            Message = "Retry exhausted: $($_.Exception.Message)"
                        } | ConvertTo-Json -Compress
                    )
                }
            )

            $stopRetry = $true
        }
        else {

            Start-Sleep -Seconds 60
            $retryCount++
        }
    }

} while ($stopRetry -eq $false)
