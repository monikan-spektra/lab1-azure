Import-Module Az.Compute
Import-Module Az.Accounts
$deployment_id     = $deployment_id
$resourceGroupName = "RG-01"
$sub_id            = $sub_id
$vmName            = "labvm-$deployment_id"
Select-AzSubscription -SubscriptionId $sub_id | Out-Null
$stopRetry = $false; [int]$retryCount = 0; $maxRetries = 3
do {
    try {
        $script = @'
if (Test-Path "C:\Automation\vm-lifecycle.ps1") {
    Write-Output "Validation Success"
} else {
    Write-Output "Validation Failed"
}
'@
        $result = Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId "RunPowerShellScript" -ScriptString $script
        $vmOutput = $result.Value[0].Message
        if ($vmOutput -match "Validation Success") {
            $message = @{ Status = "Succeeded"; Message = "Validation successful. Automation script 'vm-lifecycle.ps1' found at 'C:\Automation\' on VM '$vmName'." } | ConvertTo-Json
        } else {
            $message = @{ Status = "Failed"; Message = "Validation failed. Automation script 'vm-lifecycle.ps1' was not found at 'C:\Automation\' on VM '$vmName'. Please create the file at the correct path and try again." } | ConvertTo-Json
        }
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{ StatusCode = [System.Net.HttpStatusCode]::OK; Body = $message })
        $stopRetry = $true
    }
    catch {
        if ($retryCount -ge $maxRetries) {
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{ StatusCode = [System.Net.HttpStatusCode]::OK; Body = (@{ Status = "Failed"; Message = "Retry exhausted: $_" } | ConvertTo-Json) })
            $stopRetry = $true
        } else { Start-Sleep -Seconds 60; $retryCount++ }
    }
} while ($stopRetry -eq $false)
