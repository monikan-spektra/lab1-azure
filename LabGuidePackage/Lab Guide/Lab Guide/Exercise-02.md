# Exercise 02: Secure SSH access

## Lab Overview

In this exercise, you will harden administrative access to an Ubuntu virtual machine hosted in Azure. You will connect to the VM, review the current SSH configuration, disable root sign-in over SSH, and enforce key-based authentication. You will then validate the updated SSH configuration and restart the SSH service to apply the changes.

## Scenario

You are working as an Azure infrastructure engineer for a cloud operations team. The organization requires secure administrative access to Linux virtual machines that are deployed in Azure. Your manager has asked you to review the SSH configuration on the Ubuntu VM and update it so that root login is disabled and only key-based authentication is permitted.

Use the Azure lab environment credentials to sign in where needed:

- Username: `<inject key="AzureAdUserEmail"></inject>`
- Password: `<inject key="AzureAdUserPassword"></inject>`
- Deployment ID: **<inject key="DeploymentID" enableCopy="false"/>**

## Solution

To complete this exercise, you will connect to the Ubuntu virtual machine by using the provided lab access method. You will modify the SSH daemon configuration file to disable root login and enforce key-based authentication, verify that the authorized key is present for the intended account, test the SSH configuration syntax, and restart the SSH service safely.

## Learning Objectives

After completing this exercise, you will be able to:

- Connect to an Ubuntu virtual machine in Azure.
- Disable root SSH login on a Linux VM.
- Configure SSH to require key-based authentication.
- Validate and restart the SSH service after configuration changes.

## Environment Information

This exercise uses the Azure lab environment, Linux administration tools, and the Ubuntu virtual machine provided for the lab.

All work must be completed in the Azure subscription assigned to your lab session.

> [!Note]
> Use the exact resource names specified in the exercise steps. Validation checks depend on those names and configuration values.

## Assessment Objectives

In this exercise, you must complete the following:

1. Connect to the Ubuntu VM.
2. Disable root login and configure key-based authentication.
3. Validate and restart the SSH service.

## Detailed Instructions

### Task 1: Connect to the Ubuntu VM

In this task, you will connect to the Ubuntu virtual machine by using the provided access method.

1. Sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: `<inject key="AzureAdUserEmail"></inject>`
   - Password: `<inject key="AzureAdUserPassword"></inject>`
2. Confirm that you are working in subscription `<inject key="SubscriptionID"></inject>`` and tenant `<inject key="TenantID"></inject>`.
3. Locate the Ubuntu virtual machine that was deployed for the lab scenario.
4. Connect to the Ubuntu VM by using the access method provided in the lab environment.
5. Open a terminal session and confirm that you can run administrative commands.

> [!Tip]
> If the lab provides a browser-based connection or shared jump environment, use that method to access the Ubuntu VM before editing configuration files.

### Task 2: Disable root login and configure key-based authentication

In this task, you will update the SSH configuration to harden access to the Ubuntu VM.

1. Open the SSH daemon configuration file:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

2. Find or add the directive that disables root login and set it as shown below:

   ```bash
   PermitRootLogin no
   ```

3. Find or add the directive that disables password-based SSH authentication and set it as shown below:

   ```bash
   PasswordAuthentication no
   ```

4. Save the file and exit the editor.
5. Verify that the appropriate public key is present in the target user's `~/.ssh/authorized_keys` file.
6. Confirm that the `.ssh` folder and `authorized_keys` file have secure permissions.

> [!Important]
> Ensure that key-based access is confirmed before applying the final SSH changes. Otherwise, you might prevent remote administrative access to the VM.



### Task 3: Validate and restart the SSH service

In this task, you will validate the SSH configuration and restart the SSH service safely.

1. Test the SSH daemon configuration syntax:

   ```bash
   sudo sshd -t
   ```

2. If no errors are returned, restart the SSH service:

   ```bash
   sudo systemctl restart ssh
   ```

3. Verify that the SSH service is running correctly:

   ```bash
   sudo systemctl status ssh --no-pager
   ```

4. Confirm that root SSH login is disabled and that key-based authentication is enforced.

<validation step="Secure SSH access"/>

## Evaluation Criteria

Your work will be evaluated based on the following:

- You successfully connect to the Ubuntu virtual machine.
- Root SSH login is disabled in the SSH daemon configuration.
- Password-based SSH authentication is disabled so that key-based authentication is required.
- The SSH configuration validates successfully.
- The SSH service restarts and remains operational.

## Completion Criteria

You have completed this exercise when:

- You have connected to the Ubuntu VM.
- Root login over SSH is disabled.
- Key-based authentication is configured and available.
- The SSH configuration has been validated.
- The SSH service has been restarted successfully.

**Completed Exercise 02: Secure SSH access**
