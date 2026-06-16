Import-Module Az.Compute
Import-Module Az.Network
Import-Module Az.Resources
Import-Module Az.Accounts

$deployment_id     =  $deployment_id
$resourceGroupName = "labuser-rg"
$sub_id            = $sub_id

Select-AzSubscription -SubscriptionId $sub_id | Out-Null

$stopRetry = $false
[int]$retryCount = 0
$maxRetries = 3

do {
    try {

        $validationSuccess = $true
        $failureReasons = @()

        $rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

        if ($null -eq $rg) {
            $validationSuccess = $false
            $failureReasons += "Resource group '$resourceGroupName' does not exist."
        }

        if ($validationSuccess) {

            $resources = @(Get-AzResource -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue)

            $expectedNames = @(
                "lab-nsg",
                "lab-vnet",
                "VM-$deployment_id",
                "VM-$deployment_id-nic",
                "VM-$deployment_id-osdisk",
                "VM-$deployment_id-pip"
            )

            if ($resources.Count -ne $expectedNames.Count) {
                $validationSuccess = $false
                $failureReasons += "Expected exactly $($expectedNames.Count) resources in '$resourceGroupName'. Found $($resources.Count)."
            }

            foreach ($name in $expectedNames) {
                if ($name -notin $resources.Name) {
                    $validationSuccess = $false
                    $failureReasons += "'$name' was not found."
                }
            }

            $expectedResourceTypes = @(
                "Microsoft.Network/virtualNetworks",
                "Microsoft.Network/networkSecurityGroups",
                "Microsoft.Compute/virtualMachines",
                "Microsoft.Network/networkInterfaces",
                "Microsoft.Network/publicIPAddresses",
                "Microsoft.Compute/disks"
            )

            $unexpectedResources = $resources | Where-Object {
                $_.ResourceType -notin $expectedResourceTypes
            }

            if ($unexpectedResources.Count -gt 0) {
                $validationSuccess = $false
                $failureReasons += "Unexpected resources found: $(($unexpectedResources | Select-Object -ExpandProperty Name) -join ', ')."
            }

            $vnets = @(Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue)

            if ($vnets.Count -ne 1) {
                $validationSuccess = $false
                $failureReasons += "Exactly one Virtual Network must exist in '$resourceGroupName'."
            }
            elseif ($vnets[0].Subnets.Count -ne 1) {
                $validationSuccess = $false
                $failureReasons += "The Virtual Network must contain exactly one subnet."
            }

            $nsgs = @(Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue)

            if ($nsgs.Count -ne 1) {
                $validationSuccess = $false
                $failureReasons += "Exactly one Network Security Group must exist in '$resourceGroupName'."
            }

            $vms = @(Get-AzVM -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue)

            if ($vms.Count -ne 1) {
                $validationSuccess = $false
                $failureReasons += "Exactly one Virtual Machine must exist in '$resourceGroupName'."
            }
            else {

                $vm = $vms[0]

                if ($vm.Name -ne "VM-$deployment_id") {
                    $validationSuccess = $false
                    $failureReasons += "The Virtual Machine name must be 'VM-$deployment_id'."
                }

                if ($vm.StorageProfile.OSDisk.OsType -ne "Windows") {
                    $validationSuccess = $false
                    $failureReasons += "The Virtual Machine must be a Windows VM."
                }
            }
        }

        if ($validationSuccess) {

            $message = @{
                Status = "Succeeded"
                Message = "Validation Success. ARM deployment completed successfully. labuser-rg contains the expected resources: lab-vnet, lab-nsg, VM-$deployment_id, VM-$deployment_id-nic, VM-$deployment_id-osdisk, and VM-$deployment_id-pip."
            } | ConvertTo-Json -Compress
        }
        else {

            $message = @{
                Status = "Failed"
                Message = ($failureReasons -join " ")
            } | ConvertToJson -Compress
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
                            Status = "Failed"
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
