# **Exercise 02: Secure SSH Access**

## **Lab Overview**

In this exercise, you will harden administrative access to an Ubuntu virtual machine hosted in Azure. You will connect to the VM, review the current SSH configuration, disable root sign-in over SSH, enforce key-based authentication, verify the required SSH key files and permissions, validate the SSH configuration, and restart the SSH service.

---

## **Scenario**

You are working as an Azure infrastructure engineer for a cloud operations team. The organization requires secure administrative access to Linux virtual machines deployed in Azure. Your manager has asked you to secure SSH access by disabling root login and password-based authentication while ensuring that key-based authentication is configured correctly.

---

## **Solution**

To complete this exercise, you will connect to the existing Ubuntu virtual machine, update the SSH daemon configuration, create and verify the required authorized keys configuration, validate the SSH configuration, and restart the SSH service safely.

---

## **Learning Objectives**

After completing this exercise, you will be able to:

- Connect to an Ubuntu virtual machine using SSH.
- Disable root SSH login.
- Disable password-based SSH authentication.
- Configure and verify SSH authorized keys.
- Validate SSH daemon configuration.
- Restart and verify the SSH service.

---

## **Assessment Objectives**

In this exercise, you must complete the following:

1. Connect to the Ubuntu virtual machine.
2. Disable root SSH login.
3. Disable password-based authentication.
4. Configure the required authorized keys file and permissions.
5. Validate the SSH configuration.
6. Restart and verify the SSH service.

---

## **Detailed Instructions**

### **Task 1: Connect to the Ubuntu VM**

In this task, you will connect to the existing Ubuntu virtual machine.

**Step 1: Locate the Virtual Machine**

Navigate to **Virtual Machines** and locate:

```text
ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>
```

**Step 2: Connect Using SSH**

1. Open the VM overview page.
2. Select **Connect** > **SSH**.
3. Connect using the provided SSH command.

**Step 3: Verify Administrative Access**

Run:

```bash
sudo -i
```

Verify:

```bash
whoami
```

Expected output:

```text
root
```

### **Task 2: Disable Root Login and Password Authentication**

In this task, you will update the SSH configuration to harden access to the Ubuntu VM.

**Step 1: Edit the SSH Configuration**

Open the SSH daemon configuration file:

```bash
sudo nano /etc/ssh/sshd_config
```

Locate or add the following directives:

```text
PermitRootLogin no
PasswordAuthentication no
```

Save the file and exit.

**Step 2: Verify Configuration Entries**

Verify the `PermitRootLogin` setting:

```bash
sudo grep '^PermitRootLogin' /etc/ssh/sshd_config
```

Expected output:

```text
PermitRootLogin no
```

Verify the `PasswordAuthentication` setting:

```bash
sudo grep '^PasswordAuthentication' /etc/ssh/sshd_config
```

Expected output:

```text
PasswordAuthentication no
```

### **Task 3: Configure Authorized Keys**

In this task, you will create and configure the required SSH authorized keys file and permissions.

#### Step 1: Create the Required SSH Directory

Create the required directory:

```bash
sudo mkdir -p /home/azureuser/.ssh
```

#### Step 2: Create the Authorized Keys File

Create the file:

```bash
sudo touch /home/azureuser/.ssh/authorized_keys
```

**Step 3: Configure Permissions**

Set the required permissions:

```bash
sudo chmod 700 /home/azureuser/.ssh
sudo chmod 600 /home/azureuser/.ssh/authorized_keys
```

**Step 4: Verify Permissions**

Verify the directory permissions:

```bash
stat -c %a /home/azureuser/.ssh
```

Expected output:

```text
700
```

Verify the file permissions:

```bash
stat -c %a /home/azureuser/.ssh/authorized_keys
```

Expected output:

```text
600
```

Verify the directory exists:

```bash
ls -ld /home/azureuser/.ssh
```

Verify the file exists:

```bash
ls -l /home/azureuser/.ssh/authorized_keys
```

### **Task 4: Validate and Restart SSH**

In this task, you will validate the SSH configuration and restart the SSH service safely.

**Step 1: Validate the SSH Configuration**

Run:

```bash
sudo sshd -t
```

Expected result: No output should be returned, indicating the configuration syntax is valid.

**Step 2: Restart the SSH Service**

Restart SSH:

```bash
sudo systemctl restart ssh
```
**Step 3: Verify SSH Service Status**

Verify the service:

```bash
sudo systemctl status ssh --no-pager
```

Confirm the service state shows:

```text
active (running)
```

You may also verify:

```bash
sudo systemctl is-active ssh
```

Expected output:

```text
active
```

#### **Step 4: Final Verification**

Verify root login is disabled:

```bash
sudo grep '^PermitRootLogin' /etc/ssh/sshd_config
```

Expected output:

```text
PermitRootLogin no
```

Verify password authentication is disabled:

```bash
sudo grep '^PasswordAuthentication' /etc/ssh/sshd_config
```

Expected output:

```text
PasswordAuthentication no
```

Verify `.ssh` directory permissions:

```bash
stat -c %a /home/azureuser/.ssh
```

Expected output:

```text
700
```

Verify `authorized_keys` file permissions:

```bash
stat -c %a /home/azureuser/.ssh/authorized_keys
```

Expected output:

```text
600
```


<validation step="0b014e67-37d1-4b36-9f6c-05e3c9bf6525" />

#### **Task 4 Success Criteria**

Your solution is successful when:

- The SSH configuration validates without errors.
- The SSH service restarts and remains in an active state.
- All final verification checks return the expected values.

---

## **Evaluation Criteria**

Your submission will be evaluated based on:

**Task 1**
- Successfully connected to the Ubuntu virtual machine.

**Task 2**
- Root SSH login is disabled.
- Password authentication is disabled.

**Task 3**
- `/home/azureuser/.ssh` exists.
- `/home/azureuser/.ssh/authorized_keys` exists.
- `.ssh` permissions are set to `700`.
- `authorized_keys` permissions are set to `600`.

**Task 4**
- SSH configuration validates successfully.
- SSH service is restarted successfully.
- SSH service remains active.

---

## **Completion Criteria**

You have successfully completed this exercise when:

- You connected to the Ubuntu virtual machine.
- Root login over SSH is disabled.
- Password-based SSH authentication is disabled.
- `/home/azureuser/.ssh` exists.
- `/home/azureuser/.ssh/authorized_keys` exists.
- The `.ssh` directory permission is `700`.
- The `authorized_keys` file permission is `600`.
- The SSH configuration validates successfully.
- The SSH service is running.

---

**You have successfully completed Exercise 02: Secure SSH Access.**
