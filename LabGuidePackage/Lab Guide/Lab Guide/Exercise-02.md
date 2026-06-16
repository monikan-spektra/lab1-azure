# **Exercise 02: Secure SSH Access**

## **Lab Overview**

In this exercise, you will harden administrative access to an Ubuntu virtual machine hosted in Azure. You will connect to the VM, review the current SSH configuration, disable root sign-in over SSH, and enforce key-based authentication. You will then validate the updated SSH configuration and restart the SSH service to apply the changes.

---

## **Scenario**

You are working as an Azure infrastructure engineer for a cloud operations team. The organization requires secure administrative access to Linux virtual machines that are deployed in Azure. Your manager has asked you to create an Ubuntu virtual machine and update its SSH configuration so that root login is disabled and only key-based authentication is permitted.

---

## **Solution**

To complete this exercise, you will deploy an Ubuntu virtual machine in the assigned resource group, connect to the VM by using SSH, modify the SSH daemon configuration file to disable root login and enforce key-based authentication, verify that the authorized key is present for the intended account, test the SSH configuration syntax, and restart the SSH service safely.

---

## **Learning Objectives**

After completing this exercise, you will be able to:

- Deploy an Ubuntu virtual machine in Azure.
- Connect to an Ubuntu virtual machine using SSH.
- Disable root SSH login on a Linux VM.
- Configure SSH to require key-based authentication.
- Validate and restart the SSH service after configuration changes.

---

## **Assessment Objectives**

In this exercise, you must complete the following:

1. Create and connect to the Ubuntu virtual machine.
2. Disable root login and configure key-based authentication.
3. Validate and restart the SSH service.

---

## **Detailed Instructions**

### **Task 1: Create and Connect to the Ubuntu VM**

In this task, you will deploy an Ubuntu virtual machine and connect to it using SSH.

**Step 1: Create the Ubuntu Virtual Machine**

1. Navigate to **Virtual machines** and select **Create** > **Azure virtual machine**.

2. Configure the virtual machine using the following values:

   | Setting | Value |
   |---|---|
   | Resource Group | `labuser-rg` |
   | Virtual Machine Name | `ubuntuvm-<inject key="deploymentid" enableCopy="true"/>` |
   | Image | Ubuntu Server 22.04 LTS |
   | Size | Standard_B2s |
   | Authentication Type | SSH public key |
   | Username | `azureuser` |
   | Inbound Ports | Allow selected ports |
   | Select Inbound Ports | SSH (22) |

3. Select **Review + Create**, and then select **Create**.

4. If prompted, download the generated SSH private key and store it securely.

**Step 2: Connect to the Virtual Machine**

1. After the deployment completes, open the virtual machine overview page.

2. Select **Connect** > **SSH** and use the provided SSH connection command to connect to the virtual machine.

3. After connecting successfully, verify that you can execute administrative commands:

   ```bash
   sudo -i
   whoami
   ```

4. Confirm that the output displays:
   `root`

### **Task 2: Disable Root Login and Configure Key-Based Authentication**

In this task, you will update the SSH configuration to harden access to the Ubuntu VM.

**Step 1: Edit the SSH Daemon Configuration File**

1. Open the SSH daemon configuration file:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

2. Locate the following directive. If it does not exist, add it:

   
   `PermitRootLogin no`


3. Locate the following directive. If it does not exist, add it:

   
   `PasswordAuthentication no`
   

4. Save the file and exit the editor.

**Step 2: Verify Authorized Keys**

1. Verify that the SSH public key is present in the authorized keys file:

   ```bash
   ls -la ~/.ssh
   cat ~/.ssh/authorized_keys
   ```

2. Confirm that the `.ssh` directory and `authorized_keys` file use secure permissions:

   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

3. Verify the permissions:

   ```bash
   ls -ld ~/.ssh
   ls -l ~/.ssh/authorized_keys
   ```

4. Confirm that the output resembles the following:

   ```text
   drwx------ .ssh
   -rw------- authorized_keys
   ```

> **Important:** Ensure that key-based authentication is functioning correctly before applying the final SSH changes. Otherwise, remote administrative access to the virtual machine could be lost.


### **Task 3: Validate and Restart the SSH Service**

In this task, you will validate the SSH configuration and restart the SSH service safely.

**Step 1: Test the SSH Configuration Syntax**

1. Run the following command to validate the SSH daemon configuration:

   ```bash
   sudo sshd -t
   ```

2. Confirm that no output is returned, indicating that the configuration syntax is valid.

**Step 2: Restart the SSH Service**

1. Restart the SSH service:

   ```bash
   sudo systemctl restart ssh
   ```

2. Verify that the SSH service is running correctly:

   ```bash
   sudo systemctl status ssh --no-pager
   ```

3. Confirm that the service status displays an active state.

<validation step="0b014e67-37d1-4b36-9f6c-05e3c9bf6525" />

**Step 3: Verify Final Configuration**

Verify that root SSH login is disabled and that password-based authentication has been disabled.

**Task 3 Success Criteria**

Your solution is successful when:

- The SSH configuration validates without errors.
- The SSH service restarts and remains operational.
- Root login over SSH is confirmed as disabled.
- Password-based authentication is confirmed as disabled.
---

<validation step="0b014e67-37d1-4b36-9f6c-05e3c9bf6525" />


## **Evaluation Criteria**

Your submission will be evaluated based on:

**Task 1**
- Successful creation of the Ubuntu virtual machine with the correct name.
- Successful SSH connection to the virtual machine.

**Task 2**
- Root SSH login is disabled in the SSH daemon configuration.
- Password-based SSH authentication is disabled so that key-based authentication is required.

**Task 3**
- The SSH configuration validates successfully.
- The SSH service restarts and remains operational.

---

## **Completion Criteria**

You have successfully completed this exercise when:

- You deployed the Ubuntu virtual machine named `ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>`.
- You connected successfully to the Ubuntu VM.
- Root login over SSH is disabled.
- Key-based authentication is configured and available.
- The SSH configuration has been validated.
- The SSH service has been restarted successfully.

---

**You have successfully completed Exercise 02: Secure SSH Access.**
