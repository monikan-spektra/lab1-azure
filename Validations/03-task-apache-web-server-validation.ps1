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

dpkg -s apache2 >/dev/null 2>&1
if [ $? -ne 0 ]; then
    ok=false
fi

systemctl is-active apache2 >/dev/null 2>&1
if [ $? -ne 0 ]; then
    ok=false
fi

systemctl is-enabled apache2 >/dev/null 2>&1
if [ $? -ne 0 ]; then
    ok=false
fi

curl -I http://localhost >/tmp/http.out 2>/dev/null

grep -q "HTTP/1.1 200" /tmp/http.out
if [ $? -ne 0 ]; then
    grep -q "HTTP/2 200" /tmp/http.out
    if [ $? -ne 0 ]; then
        ok=false
    fi
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
                Message = "Apache validated successfully on '$vmName'. Apache is installed, the apache2 service is running and enabled, and localhost returns HTTP 200."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status = "Failed"
                Message = "Validation failed. Ensure Apache is installed, the apache2 service is running and enabled, and localhost returns HTTP 200."
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
                        } | ConvertToJson
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
