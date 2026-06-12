using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-lab1-$DID"
$ubuntuVmName = "ubuntu-vm"
$count = 0
$found = $false

function Get-RunCommandOutput {
    param(
        [string]$ResourceGroupName,
        [string]$VMName,
        [string]$ScriptText
    )

    $result = Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId 'RunShellScript' -ScriptString $ScriptText -ErrorAction Stop
    return (($result.Value | ForEach-Object { $_.Message }) -join "`n")
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $vm = Get-AzVM -ResourceGroupName $rg -Name $ubuntuVmName -Status -ErrorAction Stop
        $vmExists = $null -ne $vm
        $isLinux = $vm.StorageProfile.OSDisk.OsType -eq 'Linux'

        $sshConfigOutput = Get-RunCommandOutput -ResourceGroupName $rg -VMName $ubuntuVmName -ScriptText @'
if [ -f /etc/ssh/sshd_config ]; then
  root_line=$(grep -iE '^[[:space:]]*PermitRootLogin[[:space:]]+' /etc/ssh/sshd_config | tail -n 1)
  password_line=$(grep -iE '^[[:space:]]*PasswordAuthentication[[:space:]]+' /etc/ssh/sshd_config | tail -n 1)
  pubkey_line=$(grep -iE '^[[:space:]]*PubkeyAuthentication[[:space:]]+' /etc/ssh/sshd_config | tail -n 1)
  challenge_line=$(grep -iE '^[[:space:]]*ChallengeResponseAuthentication[[:space:]]+' /etc/ssh/sshd_config | tail -n 1)
  echo "PermitRootLogin=$root_line"
  echo "PasswordAuthentication=$password_line"
  echo "PubkeyAuthentication=$pubkey_line"
  echo "ChallengeResponseAuthentication=$challenge_line"
else
  echo "sshd_config missing"
fi
'@

        $rootDisabled = $sshConfigOutput -match '(?im)^PermitRootLogin=.*\bno\b'
        $passwordAuthDisabled = $sshConfigOutput -match '(?im)^PasswordAuthentication=.*\bno\b'
        $pubkeyEnabled = ($sshConfigOutput -match '(?im)^PubkeyAuthentication=.*\byes\b') -or (-not ($sshConfigOutput -match '(?im)^PubkeyAuthentication='))

        if ($vmExists -and $isLinux -and $rootDisabled -and $passwordAuthDisabled -and $pubkeyEnabled) {
            $found = $true
            $message = @{
                Status  = "Succeeded"
                Message = "Ubuntu VM '$ubuntuVmName' exists in RG '$rg' and SSH is hardened with PermitRootLogin no, PasswordAuthentication no, and key-based authentication enabled."
            } | ConvertTo-Json
        } else {
            $details = @()
            if (-not $vmExists) { $details += "Ubuntu VM '$ubuntuVmName' was not found" }
            if ($vmExists -and -not $isLinux) { $details += "VM '$ubuntuVmName' is not a Linux VM" }
            if (-not $rootDisabled) { $details += "PermitRootLogin is not set to no" }
            if (-not $passwordAuthDisabled) { $details += "PasswordAuthentication is not set to no" }
            if (-not $pubkeyEnabled) { $details += "PubkeyAuthentication is not enabled" }
            $message = @{
                Status  = "Failed"
                Message = (($details -join '; ') + ". Checked VM '$ubuntuVmName' in RG '$rg'.")
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

if (-not $found) {
    $message = @{
        Status  = "Failed"
        Message = "Ubuntu VM '$ubuntuVmName' with required SSH hardening was not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
