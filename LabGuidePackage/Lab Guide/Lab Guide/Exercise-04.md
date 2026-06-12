# Exercise 04: Automate Azure VM Start/Stop

## Lab Overview

In this exercise, you will use Azure PowerShell to manage the power state of Azure virtual machines in the lab environment. You will connect to Azure, confirm the active subscription context, stop and start virtual machines, and verify that the resources return the expected status.

## Scenario

You are continuing your work as an Azure infrastructure engineer on the cloud operations team.

Your manager has asked you to automate virtual machine lifecycle operations so the team can consistently manage compute costs and operational availability. To complete this scenario, you must use Azure PowerShell to authenticate to Azure, stop and start the required virtual machines, and confirm that the final VM power states are correct.

## Solution

To complete this scenario, you will sign in to Azure by using Azure PowerShell with the lab credentials, verify that you are working in subscription `<inject key="SubscriptionID"></inject>`, use Az PowerShell cmdlets to stop and start the Azure virtual machines, and then confirm the final power state of each VM.

## Learning Objectives

After completing this exercise, you will be able to:

- Authenticate to Azure by using Azure PowerShell.
- Stop and start Azure virtual machines by using Az PowerShell cmdlets.
- Verify Azure virtual machine power states.

## Environment Information

- Azure portal: <https://portal.azure.com>
- Azure sign-in account: `<inject key="AzureAdUserEmail"></inject>`
- Azure password: `<inject key="AzureAdUserPassword"></inject>`
- Azure subscription: `<inject key="SubscriptionID"></inject>`
- Azure tenant: `<inject key="TenantID"></inject>`
- Deployment ID: **<inject key="DeploymentID" enableCopy="false"></inject>**

> [!Note]
> Use the exact resource names created earlier in the lab. Validation checks depend on the expected VM names and power state.

## Assessment Objectives

1. Authenticate with Azure PowerShell.
2. Stop and start the Azure virtual machines.
3. Verify the VM power states.

## Detailed Instructions

### Task 1: Authenticate with Azure PowerShell

1. Sign in to the lab virtual machine or workstation that you have been using for this lab.
2. Open **Windows PowerShell** or **PowerShell 7**.
3. Sign in to Azure by running the following command:

   ```powershell
   Connect-AzAccount
   ```

4. When prompted, sign in with the following credentials:
   - Username: `<inject key="AzureAdUserEmail"></inject>`
   - Password: `<inject key="AzureAdUserPassword"></inject>`

5. If needed, confirm that the correct subscription is selected:

   ```powershell
   Get-AzContext
   ```

6. If the active subscription is not `<inject key="SubscriptionID"></inject>`, set the correct subscription context:

   ```powershell
   Set-AzContext -Subscription '<inject key="SubscriptionID"></inject>'
   ```

7. Verify that the Azure context shows the expected account, tenant, and subscription.

### Task 2: Stop and start the Azure virtual machines

1. Review the virtual machines available in the current subscription:

   ```powershell
   Get-AzVM -Status
   ```

2. Identify the Windows virtual machine deployed earlier in the lab and the Ubuntu virtual machine deployed during the Linux scenario.
3. Stop one of the target virtual machines by using Azure PowerShell. Use the exact **ResourceGroupName** and **Name** values returned by the previous command:

   ```powershell
   Stop-AzVM -ResourceGroupName 'your-resource-group-name' -Name 'your-vm-name' -Force
   ```

4. Repeat the command for the second target virtual machine.
5. Start the same virtual machines again. Use the exact **ResourceGroupName** and **Name** values returned by `Get-AzVM -Status`:

   ```powershell
   Start-AzVM -ResourceGroupName 'your-resource-group-name' -Name 'your-vm-name'
   ```

6. Repeat the command for the second target virtual machine.

> [!Tip]
> If you need to confirm the resource group and VM names before running the stop and start commands, use `Get-AzVM -Status | Format-Table Name, ResourceGroupName, PowerState`.

### Task 3: Verify the VM power states

1. Retrieve the current power state of the virtual machines:

   ```powershell
   Get-AzVM -Status | Format-Table Name, ResourceGroupName, PowerState
   ```

2. Confirm that the target virtual machines show a running state.
3. Review the output carefully and make sure the expected Azure virtual machines are available and operational.
4. Save your work if your instructor or lab workflow requires it.

<validation step="5efa3b45-81c0-442f-9755-ebdcf943e908"/>

## Evaluation Criteria

The exercise is complete when the following conditions are met:

- Azure authentication through Azure PowerShell succeeds.
- The required Azure virtual machines are stopped successfully.
- The same Azure virtual machines are started successfully.
- The final VM power state output confirms that the required virtual machines are running.

## Completion Criteria

You have completed this exercise when you have authenticated to Azure with PowerShell, stopped and started the required virtual machines, and verified that the expected VM power states are correct.

**Completed Exercise 04: Automate Azure VM Start/Stop**
