Param(
    [Parameter(Mandatory = $false)]
    [string]$AzureUserName,

    [Parameter(Mandatory = $false)]
    [string]$AzurePassword,

    [Parameter(Mandatory = $false)]
    [string]$AzureTenantID,

    [Parameter(Mandatory = $false)]
    [string]$AzureSubscriptionID,

    [Parameter(Mandatory = $false)]
    [string]$ODLID,

    [Parameter(Mandatory = $false)]
    [string]$InstallCloudLabsShadow,

    [Parameter(Mandatory = $false)]
    [string]$DeploymentID,

    [Parameter(Mandatory = $false)]
    [string]$vmAdminUsername,

    [Parameter(Mandatory = $false)]
    [string]$vmAdminPassword,

    [Parameter(Mandatory = $false)]
    [string]$trainerUserName,

    [Parameter(Mandatory = $false)]
    [string]$trainerUserPassword
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Start-Transcript -Path 'C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt' -Append

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $labFilesPath = 'C:\LabFiles'
    $publicDesktop = 'C:\Users\Public\Desktop'
    $commonBase = 'https://experienceazure.blob.core.windows.net/templates/cloudlabs-common'
    $credTxtUrl = "$commonBase/AzureCreds.txt"
    $credPs1Url = "$commonBase/AzureCreds.ps1"
    $shadowUrl = "$commonBase/ShadowSetup.ps1"

    New-Item -Path $labFilesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $publicDesktop -ItemType Directory -Force | Out-Null

    function Invoke-CloudLabsDownload {
        param(
            [Parameter(Mandatory = $true)][string]$Url,
            [Parameter(Mandatory = $true)][string]$Destination
        )

        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
    }

    function CreateCredFile {
        $azureCredsTxtLocal = Join-Path $env:TEMP 'AzureCreds.txt'
        $azureCredsPs1Local = Join-Path $env:TEMP 'AzureCreds.ps1'

        Invoke-CloudLabsDownload -Url $credTxtUrl -Destination $azureCredsTxtLocal
        Invoke-CloudLabsDownload -Url $credPs1Url -Destination $azureCredsPs1Local

        $credContent = Get-Content -Path $azureCredsTxtLocal -Raw
        $credContent = $credContent.Replace('AzureUserNameValue', $AzureUserName)
        $credContent = $credContent.Replace('AzurePasswordValue', $AzurePassword)
        $credContent = $credContent.Replace('AzureTenantIDValue', $AzureTenantID)
        $credContent = $credContent.Replace('AzureSubscriptionIDValue', $AzureSubscriptionID)
        $credContent = $credContent.Replace('ODLIDValue', $ODLID)
        $credContent = $credContent.Replace('DeploymentIDValue', $DeploymentID)

        $credTxtDestination = Join-Path $labFilesPath 'AzureCreds.txt'
        $credPs1Destination = Join-Path $labFilesPath 'AzureCreds.ps1'
        Set-Content -Path $credTxtDestination -Value $credContent -Force
        Copy-Item -Path $credTxtDestination -Destination (Join-Path $publicDesktop 'AzureCreds.txt') -Force
        Copy-Item -Path $azureCredsPs1Local -Destination $credPs1Destination -Force
        Copy-Item -Path $azureCredsPs1Local -Destination (Join-Path $publicDesktop 'AzureCreds.ps1') -Force
    }

    function Install-ChocolateyIfNeeded {
        if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
    }

    function Install-LabTools {
        Install-ChocolateyIfNeeded

        choco feature enable -n allowGlobalConfirmation | Out-Null

        $packages = @(
            'azure-cli',
            'git',
            'vscode',
            'notepadplusplus',
            'googlechrome',
            'putty',
            'winscp',
            'jq',
            'curl'
        )

        foreach ($package in $packages) {
            choco install $package --no-progress -y
        }

        Install-PackageProvider -Name NuGet -Force -Scope AllUsers | Out-Null
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Install-Module -Name Az -Repository PSGallery -Force -AllowClobber -Scope AllUsers

        $codeCmd = 'C:\Program Files\Microsoft VS Code\bin\code.cmd'
        if (Test-Path $codeCmd) {
            & $codeCmd --install-extension ms-azuretools.vscode-azureresourcegroups --force
            & $codeCmd --install-extension ms-vscode.powershell --force
            & $codeCmd --install-extension redhat.vscode-yaml --force
            & $codeCmd --install-extension ms-azuretools.vscode-bicep --force
            & $codeCmd --install-extension ms-vscode.remote-ssh --force
        }
    }

    function New-LabResources {
        $readmePath = Join-Path $labFilesPath 'Lab-Environment-Notes.txt'
        @"
Azure Lab VM Preparation Complete
=================================

This workstation has been prepared for the Azure, PowerShell, Windows and Linux lab.

Installed tools:
- Azure CLI
- Azure PowerShell Az module
- Git
- Visual Studio Code
- PuTTY
- WinSCP
- Chrome
- Notepad++
- jq and curl

Suggested learner workflow:
1. Review the ARM template and parameter files from the deployment package.
2. Use Azure PowerShell or Azure CLI to sign in with the provided credentials.
3. Deploy and verify the Azure infrastructure.
4. Connect to the Ubuntu VM with SSH and perform SSH hardening tasks.
5. Install and validate Apache or Nginx on Ubuntu.
6. Start and stop Azure VMs by using Az PowerShell cmdlets.

Helpful file locations:
- C:\LabFiles\AzureCreds.txt
- C:\LabFiles\AzureCreds.ps1
- C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt
"@ | Set-Content -Path $readmePath -Force

        $desktopNote = Join-Path $publicDesktop 'Lab-Environment-Notes.txt'
        Copy-Item -Path $readmePath -Destination $desktopNote -Force

        $quickStartPs1 = Join-Path $labFilesPath 'Connect-AzureLab.ps1'
        @"
`$securePassword = ConvertTo-SecureString '$AzurePassword' -AsPlainText -Force
`$credential = New-Object System.Management.Automation.PSCredential('$AzureUserName', `$securePassword)
Connect-AzAccount -Credential `$credential -Tenant '$AzureTenantID' -Subscription '$AzureSubscriptionID'
"@ | Set-Content -Path $quickStartPs1 -Force
        Copy-Item -Path $quickStartPs1 -Destination (Join-Path $publicDesktop 'Connect-AzureLab.ps1') -Force
    }

    function Install-CloudLabsShadowIfRequested {
        if ($InstallCloudLabsShadow -and $InstallCloudLabsShadow.ToString().ToLower() -eq 'true') {
            $shadowScript = Join-Path $env:TEMP 'ShadowSetup.ps1'
            Invoke-CloudLabsDownload -Url $shadowUrl -Destination $shadowScript
            & powershell.exe -ExecutionPolicy Bypass -File $shadowScript
        }
    }

    CreateCredFile
    Install-CloudLabsShadowIfRequested
    Install-LabTools
    New-LabResources

    Write-Host 'CloudLabs Azure lab VM bootstrap completed successfully.'
}
catch {
    Write-Error $_.Exception.Message
    throw
}
finally {
    Stop-Transcript
}
