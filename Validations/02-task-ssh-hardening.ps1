Import-Module Az.Compute
Import-Module Az.Accounts

$deployment_id     = $deployment_id
$resourceGroupName = "RG-01"
$sub_id            = $sub_id
$vmName            = "ubuntuvm-$deployment_id"

Select-AzSubscription -SubscriptionId $sub_id | Out-Null

$stopRetry = $false
[int]$retryCount = 0
$maxRetries = 3

do {
    try {

        $script = @'
ok=true

if ! grep -Eq "^[[:space:]]*PermitRootLogin[[:space:]]+no" /etc/ssh/sshd_config; then
    ok=false
fi

if ! grep -Eq "^[[:space:]]*PasswordAuthentication[[:space:]]+no" /etc/ssh/sshd_config; then
    ok=false
fi

if [ ! -f /home/azureuser/.ssh/authorized_keys ]; then
    ok=false
fi

if [ "$(stat -c %a /home/azureuser/.ssh 2>/dev/null)" != "700" ]; then
    ok=false
fi

if [ "$(stat -c %a /home/azureuser/.ssh/authorized_keys 2>/dev/null)" != "600" ]; then
    ok=false
fi

sshd -t >/dev/null 2>&1
if [ $? -ne 0 ]; then
    ok=false
fi

systemctl is-active ssh >/dev/null 2>&1
if [ $? -ne 0 ]; then
    ok=false
fi

if [ "$ok" = true ]; then
    echo "Validation Success"
else
    echo "Validation Failed"
fi
'@

        $result = Invoke-AzVMRunCommand `
            -ResourceGroupName $resourceGroupName `
            -VMName $vmName `
            -CommandId "RunShellScript" `
            -ScriptString $script

        $vmOutput = $result.Value[0].Message

        if ($vmOutput -match "Validation Success") {

            $message = @{
                Status = "Succeeded"
                Message = "SSH hardening validated successfully on '$vmName'. Root login is disabled, password authentication is disabled, authorized_keys exists with secure permissions, SSH configuration is valid, and the SSH service is running."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status = "Failed"
                Message = "Validation failed. Ensure PermitRootLogin=no, PasswordAuthentication=no, authorized_keys exists, .ssh permissions are 700, authorized_keys permissions are 600, sshd -t succeeds, and the SSH service is active."
            } | ConvertTo-Json
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
                        } | ConvertTo-Json
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
