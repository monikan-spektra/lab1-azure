# Exercise 03: Configure Ubuntu VM as a Web Server

## Lab Overview

In this exercise, you will configure the existing Ubuntu virtual machine in Azure to host a basic web server. You will install the Apache web server, start and enable the Apache service, and verify that the default web page is available locally from the Ubuntu virtual machine.

---

## Scenario

You are working as an Azure infrastructure engineer for a cloud operations team. The organization requires a Linux virtual machine that can be used for administration and application hosting tasks. Your manager has asked you to prepare the existing Ubuntu virtual machine to serve web content for testing and validation purposes.

---

## Solution

To complete this scenario, you will connect to the existing Ubuntu virtual machine, install the Apache web server, start and enable the Apache service, and verify that the Apache default web page is accessible from the local system.

---

## Learning Objectives

After completing this exercise, you will be able to:

- Connect to an Ubuntu virtual machine in Azure.
- Install Apache on Ubuntu.
- Start and enable the Apache service.
- Verify web server functionality using the default Apache page.

---

## Environment Information

You have been provided access to:

- Azure Portal
- Azure Subscription with appropriate permissions
- An existing Ubuntu virtual machine deployed in the lab resource group

Use the following credentials:

| Field | Value |
|---|---|
| Username | `<inject key="AzureAdUserEmail" enableCopy="true"/>` |
| Password | `<inject key="AzureAdUserPassword" enableCopy="true"/>` |
| Subscription | `<inject key="SubscriptionID" enableCopy="true"/>` |
| Tenant | `<inject key="TenantID" enableCopy="true"/>` |
| Deployment ID | `<inject key="DeploymentID" enableCopy="true"/>` |
| Resource Group | `labuser-rg` |
| Ubuntu VM Name | `ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>` |

> **Note:** Use the exact virtual machine name specified above. Validation checks depend on the expected resource name and service configuration.

---

## Assessment Objectives

In this exercise, you must complete the following:

1. Connect to the Ubuntu virtual machine.
2. Install Apache.
3. Start and enable the Apache service.
4. Verify that the Apache default page is returned locally.

---

## Detailed Instructions

### Task 1: Connect to the Ubuntu VM

In this task, you will connect to the existing Ubuntu virtual machine.

#### Step 1: Locate the Virtual Machine

1. Sign in to the Azure portal at [https://portal.azure.com](https://portal.azure.com) using:

   | Field | Value |
   |---|---|
   | Username | `<inject key="AzureAdUserEmail" enableCopy="true"/>` |
   | Password | `<inject key="AzureAdUserPassword" enableCopy="true"/>` |

2. Navigate to **Virtual machines** and locate the VM named:

   ```
   ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>
   ```

#### Step 2: Open a Terminal Session

1. Connect to the Ubuntu virtual machine using the access method provided by the lab environment.

2. Open a terminal session.

3. Verify that you can execute administrative commands:

   ```bash
   sudo -i
   ```

4. Exit the root shell when verification is complete:

   ```bash
   exit
   ```

#### Task 1 Success Criteria

Your solution is successful when:

- You have located the Ubuntu virtual machine in the Azure portal.
- You have connected successfully to the VM.
- You can execute administrative commands in the terminal.

---

### Task 2: Install Apache

In this task, you will install the Apache web server.

#### Step 1: Update the Package Repository

Run the following command to update the package list:

```bash
sudo apt-get update
```

#### Step 2: Install Apache

Install the Apache web server:

```bash
sudo apt-get install apache2 -y
```

#### Step 3: Verify the Installation

1. Verify that Apache is installed:

   ```bash
   apache2 -v
   ```

2. Confirm that the Apache package information can be displayed:

   ```bash
   apt show apache2
   ```

#### Task 2 Success Criteria

Your solution is successful when:

- The package repository is updated successfully.
- Apache is installed without errors.
- The Apache version is displayed confirming a successful installation.

---

### Task 3: Start and Verify Apache

In this task, you will start Apache and verify that the default web page is available.

#### Step 1: Start the Apache Service

Start the Apache service:

```bash
sudo systemctl start apache2
```

#### Step 2: Enable Apache on Boot

Configure Apache to start automatically after system reboot:

```bash
sudo systemctl enable apache2
```

#### Step 3: Verify the Apache Service

1. Verify that the Apache service is running:

   ```bash
   sudo systemctl status apache2 --no-pager
   ```

2. Verify that Apache is enabled:

   ```bash
   sudo systemctl is-enabled apache2
   ```

#### Step 4: Test the Local Web Response

1. Test the local web response:

   ```bash
   curl -I http://localhost
   ```

2. Verify that the default Apache page is returned:

   ```bash
   curl http://localhost | grep "Apache2 Ubuntu Default Page"
   ```

3. Confirm that the output contains:

   ```
   Apache2 Ubuntu Default Page
   ```
<validation step="ed5bdf6a-341c-4c8b-b94b-682adf0acff5" />

#### Task 3 Success Criteria

Your solution is successful when:

- The Apache service is running and shows an active state.
- Apache is enabled to start automatically on reboot.
- The default Apache page is returned from `http://localhost`.

---

## Evaluation Criteria

Your submission will be evaluated based on:

**Task 1**
- Successful connection to the Ubuntu virtual machine.

**Task 2**
- Apache was installed successfully.

**Task 3**
- The Apache service was started successfully.
- The Apache service was configured to start automatically.
- The Apache default page was returned from the local web server.

---

## Completion Criteria

You have successfully completed this exercise when:

- You connected to the Ubuntu virtual machine.
- Apache was installed successfully.
- The Apache service is running.
- Apache is enabled to start automatically.
- The default Apache page is returned from `http://localhost`.

---

**You have successfully completed Exercise 03: Configure Ubuntu VM as a Web Server.**
