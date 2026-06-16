# **Exercise 04: Automate Azure VM Start/Stop**
 
## **Lab Overview**
 
In this exercise, you will use Azure PowerShell to manage the power state of Azure virtual machines in the lab environment. You will install the required Azure PowerShell modules, connect to Azure, create an automation script, and run it to stop and start virtual machines.
 
## **Scenario**
 
You are continuing your work as an Azure infrastructure engineer on the cloud operations team.
 
Your manager has asked you to automate virtual machine lifecycle operations so the team can consistently manage compute costs and operational availability. To complete this scenario, you must install Azure PowerShell modules, authenticate to Azure, create an automation script at a specific path, and run it to stop and start the required virtual machines.
 
## **Solution**
 
To complete this scenario, you will install the required Az PowerShell modules on the lab virtual machine, sign in to Azure using device authentication, create the automation script at `C:\Automation\vm-lifecycle.ps1`, and run it to stop and start the Azure virtual machines.
 
## **Learning Objectives**
 
After completing this exercise, you will be able to:
 
- Install Azure PowerShell modules on a Windows machine.
- Authenticate to Azure by using Azure PowerShell with device authentication.
- Create and run an automation script to stop and start Azure virtual machines.
- Verify Azure virtual machine power states.
 
## **Assessment Objectives**
 
1. Install Azure PowerShell modules.
2. Authenticate with Azure PowerShell using device authentication.
3. Create the automation script at `C:\Automation\vm-lifecycle.ps1`.
4. Run the script to stop and start the Azure virtual machines.
5. Verify the VM power states.
   
## **Detailed Instructions**
 
**Task 1: Install Azure PowerShell Modules**
 
1. Sign in to the lab virtual machine or workstation that you have been using for this lab.
2. Open **Windows PowerShell** or **PowerShell 7** as Administrator.
3. Run the following commands one by one to install the required Azure PowerShell modules:
   
```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```
 
```powershell
   Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
```
 
```powershell
   Install-Module Az.Accounts -Scope CurrentUser -Force
```
 
```powershell
   Install-Module Az.Compute -Scope CurrentUser -Force
```
 
4. Wait for all modules to install successfully before proceeding.
> [!Note]
> If prompted to confirm installation from an untrusted repository, type `Y` and press **Enter** to continue.
 
**Task 2: Authenticate with Azure PowerShell**
 
1. In the same PowerShell window, run the following command to sign in to Azure using device authentication:
```powershell
   Connect-AzAccount -UseDeviceAuthentication
```
 
2. A device code will be displayed in the terminal output, for example:
```
   To sign in, use a web browser to open the page https://microsoft.com/devicelogin
   and enter the code XXXXXXXXX to authenticate.
```
 
3. Open a browser and navigate to <https://microsoft.com/devicelogin>.
4. Enter the code displayed in your terminal and click **Next**.
5. Sign in with the following credentials when prompted:
  
6. After successful authentication, return to the PowerShell window. Confirm that the correct subscription is selected:
```powershell
   Get-AzContext
```
 
7. Verify that the Azure context shows the expected account, tenant, and subscription.
   
**Task 3: Create the Automation Script**
 
1. Create the `C:\Automation` directory if it does not already exist:
```powershell
   New-Item -ItemType Directory -Path "C:\Automation" -Force
```
 
2. Create the automation script file at `C:\Automation\vm-lifecycle.ps1`:
```powershell
   New-Item -ItemType File -Path "C:\Automation\vm-lifecycle.ps1" -Force
```
 
3. Open the file in Notepad or your preferred editor and add the following content, replacing the placeholder values with the actual resource group name and VM names from your environment:
 
4. Save the file at `C:\Automation\vm-lifecycle.ps1`.
> [!Note]
> Make sure the file is saved exactly at `C:\Automation\vm-lifecycle.ps1`. The validation check depends on the exact path and file name.
 
**Task 4: Run the Automation Script**
 
1. In the PowerShell window, run the automation script:
```powershell
   & "C:\Automation\vm-lifecycle.ps1"
```
 
2. Wait for the script to complete. You will see output messages as each VM is stopped and started.
3. Review the final output table to confirm both VMs show a running state.
> [!Tip]
> If you need to check the VM names and resource group before running the script, use:
> ```powershell
> Get-AzVM -Status | Format-Table Name, ResourceGroupName, PowerState
> ```
 
**Task 5: Verify the VM Power States**
 
1. Retrieve the current power state of the virtual machines:
```powershell
   Get-AzVM -Status | Format-Table Name, ResourceGroupName, PowerState
```
 
2. Confirm that both target virtual machines show **VM running** in the PowerState column.
3. Review the output carefully and make sure the expected Azure virtual machines are available and operational.
   
<validation step="5efa3b45-81c0-442f-9755-ebdcf943e908" />

## **Evaluation Criteria
 
The exercise is complete when the following conditions are met:
 
- Azure PowerShell modules are installed successfully.
- Azure authentication through Azure PowerShell with device authentication succeeds.
- The automation script exists at `C:\Automation\vm-lifecycle.ps1`.
- The required Azure virtual machines are stopped and started successfully by the script.
- The final VM power state output confirms that the required virtual machines are running.
  
## Completion Criteria
 
You have completed this exercise when you have installed the required Azure PowerShell modules, authenticated to Azure using device authentication, created and run the automation script at `C:\Automation\vm-lifecycle.ps1`, and verified that the expected VM power states are running.
 
**Completed Exercise 04: Automate Azure VM Start/Stop**
