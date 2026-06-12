# Exercise 03: Deploy Ubuntu VM and configure as web server

## Lab Overview

In this exercise, you will deploy an Ubuntu virtual machine in Azure and configure it to host a basic web server. You will create the Linux virtual machine in the existing lab environment, allow HTTP access, install Apache, and verify that the default web page is available.

## Scenario

You are working as an Azure infrastructure engineer for a cloud operations team. The organization requires a Linux virtual machine that can be used for administration and application hosting tasks. Your manager has asked you to deploy an Ubuntu VM into the existing Azure environment and prepare it to serve web content for testing and validation.

## Solution

To complete this scenario, you will deploy an Ubuntu VM into the existing resource group and virtual network, configure network access for HTTP traffic, install the Apache web server on the Linux VM, and verify that the Apache default web page is accessible.

## Learning Objectives

After completing this exercise, you will be able to:

- Deploy an Ubuntu virtual machine in Azure.
- Configure HTTP access for a Linux web server.
- Install Apache on Ubuntu.
- Start the Apache service and verify web server functionality.

## Environment Information

- Azure portal: <https://portal.azure.com>
- Username: <inject key="AzureAdUserEmail"></inject>
- Password: <inject key="AzureAdUserPassword"></inject>
- Subscription: <inject key="SubscriptionID"></inject>
- Tenant: <inject key="TenantID"></inject>
- Deployment ID: **<inject key="DeploymentID" enableCopy="false"/>**

> [!Note]
> Use the exact resource names specified in the steps. Validation depends on those names.

## Assessment Objectives

1. Deploy the Ubuntu VM.
2. Configure HTTP access and install Apache.
3. Start Apache and verify the default web page.

## Detailed Instructions

### Task 1: Deploy the Ubuntu VM

1. Sign in to the Azure portal at <https://portal.azure.com> by using **<inject key="AzureAdUserEmail"></inject>** and **<inject key="AzureAdUserPassword"></inject>**.
2. In the Azure portal, confirm that you are working in subscription **<inject key="SubscriptionID"></inject>**.
3. Open **Cloud Shell** and select **Bash**.
4. Run the following commands to set variables for the deployment:

   ```bash
   RG_NAME="rg-<inject key="DeploymentID"></inject>"
   VNET_NAME="vnet-lab"
   SUBNET_NAME="subnet-workload"
   VM_NAME="ubuntuvm01"
   ADMIN_USER="azureuser"
   ```

5. Create the Ubuntu virtual machine by running the following command:

   ```bash
   az vm create \
     --resource-group $RG_NAME \
     --name $VM_NAME \
     --image Ubuntu2204 \
     --admin-username $ADMIN_USER \
     --generate-ssh-keys \
     --vnet-name $VNET_NAME \
     --subnet $SUBNET_NAME \
     --public-ip-sku Standard
   ```

6. Wait for the deployment to complete successfully.
7. Record the public IP address returned by the deployment output.

### Task 2: Configure HTTP access and install Apache

1. In Cloud Shell, open TCP port 80 for the Ubuntu VM:

   ```bash
   az vm open-port \
     --resource-group $RG_NAME \
     --name $VM_NAME \
     --port 80
   ```

2. Connect to the Ubuntu VM by using SSH and the public IP address returned from the previous step.
3. Update the package list:

   ```bash
   sudo apt-get update
   ```

4. Install Apache:

   ```bash
   sudo apt-get install apache2 -y
   ```

5. Verify that Apache is installed:

   ```bash
   apache2 -v
   ```

### Task 3: Start Apache and verify the default web page

1. Start the Apache service:

   ```bash
   sudo systemctl start apache2
   ```

2. Enable Apache to start automatically when the VM starts:

   ```bash
   sudo systemctl enable apache2
   ```

3. Verify that the Apache service is running:

   ```bash
   sudo systemctl status apache2
   ```

4. From the Ubuntu VM, test the local web response:

   ```bash
   curl http://localhost
   ```

5. In a browser, browse to the public IP address that was returned when you created the Ubuntu VM and confirm that the Apache default page is displayed.

<question>

<validation step="ed5bdf6a-341c-4c8b-b94b-682adf0acff5"/>

## Evaluation Criteria

Your work will be evaluated based on the following:

- The Ubuntu VM is deployed successfully in Azure.
- HTTP access is configured correctly.
- Apache is installed on the Ubuntu VM.
- The Apache service is running.
- The default Apache web page is accessible.

## Completion Criteria

You have successfully completed this exercise when you have deployed the Ubuntu virtual machine, configured HTTP access, installed Apache, and verified that the default Apache page is available.

**Completed Exercise 03: Deploy Ubuntu VM and configure as web server**
