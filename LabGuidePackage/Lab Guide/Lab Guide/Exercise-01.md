# **Exercise 01: Deploy Infrastructure Using ARM Template**

## **Lab Overview**

In this exercise, you will deploy the base Azure infrastructure required for the remaining lab scenarios by using an Azure Resource Manager (ARM) template.

The deployment will provision a Windows virtual machine along with the networking components required to access and manage it. You will review the deployment files, confirm the deployment requirements, and validate that the expected resources were created successfully.

---

## **Scenario**

You have recently joined the Cloud Operations team as an Azure Infrastructure Engineer.

To prepare the environment for upcoming Windows and Linux administration tasks, your manager has asked you to deploy the foundational Azure infrastructure using an ARM template.

You have been provided access to an Azure subscription and must deploy the resources according to the organization's naming standards and deployment requirements.

---

## **Solution**

To address this requirement, you will review the provided ARM template and parameter file, then perform a custom deployment through the Azure portal.

The deployment will create the networking infrastructure and a Windows virtual machine that will be used throughout the remainder of the lab.

This exercise demonstrates common Azure infrastructure deployment tasks frequently performed by cloud administrators and operations engineers.

---

## **Learning Objectives**

After completing this exercise, you will be able to:

- Sign in to Azure and verify the correct subscription context.
- Review ARM templates and parameter files.
- Deploy Azure infrastructure using an ARM template.
- Verify deployed Azure resources.
- Understand resource naming conventions used in ARM deployments.

---

## **Assessment Objectives**

### **Task 1: Review Deployment Requirements**

Review the deployment requirements and confirm that you understand:

- The target Azure subscription.
- The deployment identifier.
- The resource naming requirements.
- The ARM deployment files.

### **Task 2: Review the ARM Template and Parameter File**

Confirm that the ARM deployment defines:

- One Virtual Network
- One Subnet
- One Network Security Group
- One Windows Virtual Machine
- One Network Interface
- One Public IP Address
- One Managed OS Disk

### **Task 3: Deploy and Verify the Infrastructure**

Deploy the ARM template and verify that all required resources were provisioned successfully.

---

## **Detailed Instructions**

### **Task 1: Review Deployment Requirements**

 **Step 1: Sign in to Azure**

Open a browser and navigate to: [https://portal.azure.com](https://portal.azure.com)

Sign in using:


 Username :  <inject key="azureaduseremail" enableCopy="false" /> 
 Password :  <inject key="azureaduserpassword" enableCopy="false" /> 

**Step 2: Verify Subscription Context**

After signing in, confirm that you are working in:

| Field | Value |
|---|---|
| Subscription | `<inject key="subscriptionid">` |
| Tenant | `<inject key="tenantid">` |

**Step 3: Review Deployment Information**

| Field | Value |
|---|---|
| Deployment Identifier | `<inject key="deploymentid"/>` |
| Deployment Region | `<inject key="location"/>` |
| Resource Group | `labuser-rg` |

**Step 4: Review Required Resource Names**

Your deployment must create the following resources exactly as shown below:

| Resource Type | Required Resource Name |
|---|---|
| Virtual Network | `lab-vnet` |
| Network Security Group | `lab-nsg` |
| Windows Virtual Machine | `VM-<inject key="DeploymentID"/>` |
| Network Interface | `VM-<inject key="deploymentid"/>-nic` |
| Public IP Address | `VM-<inject key="deploymentid"/>-pip` |
| Managed OS Disk | `VM-<inject key="deploymentid"/>-osdisk` |

> **Important:** Validation will fail if any required resource uses a different name.

### **Task 2: Review the ARM Template and Parameter File**

 **Step 1: Open the ARM Template**

- Open the provided ARM template file.
- Review the resources defined within the template.

 **Step 2: Open the Parameter File**

- Open the parameter file supplied with the lab.
- Review the parameter values that will be used during deployment.

 **Step 3: Verify Template Components**

Confirm that the template defines the following resources:

- One Virtual Network
- One Subnet
- One Network Security Group
- One Windows Virtual Machine
- One Network Interface
- One Public IP Address
- One Managed Disk

**Step 4: Verify VM Configuration**

Ensure that the virtual machine deployment uses:

| Field | Value |
|---|---|
| Virtual Machine Name | `ubuntuvm-<inject key="ubuntuvm"/>` |
| Operating System | linux |
| Administrator Username | `<inject key="LabVM Admin Username"/>` |
| Administrator Password | `<inject key="LabVM Admin Password"/>` |
  
### **Task 3: Deploy and Verify the Infrastructure**

 **Step 1: Start a Custom Deployment**

1. In the Azure portal, search for: **Deploy a custom template**
2. Choose: **Build your own template in the editor**
3. Upload the provided ARM template.
4. Upload the parameter file when prompted.

**Step 2: Configure Deployment Details**

| Field | Value |
|---|---|
| Subscription | `<inject key="subscriptionid">` |
| Resource Group | `labuser-rg` |
| Region | `<inject key="location"/>` |

- Review the deployment settings.
- Choose **Review + Create**, then select **Create**.

**Step 3: Wait for Deployment Completion**

Monitor the deployment until the status displays:

> **Your deployment is complete.**

**Step 4: Verify Required Resources**

Navigate to the resource group `labuser-rg` and confirm that the following resources exist:

| Resource Type | Expected Resource Name |
|---|---|
| Virtual Network | `lab-vnet` |
| Network Security Group | `lab-nsg` |
| Virtual Machine | `ubuntuvm-<inject key="deploymentid"/>` |
| Network Interface | `ubuntuvm-<inject key="deploymentid"/>-nic` |
| Public IP Address | `ubuntuvm-<inject key="deploymentid"/>-pip` |
| Managed Disk | `ubuntuvm-<inject key="deploymentid"/>-osdisk` |

**Step 5: Verify Networking Configuration**

Confirm that:

- Exactly one Virtual Network exists.
- The Virtual Network contains exactly one subnet.
- Exactly one Network Security Group exists.

**Step 6: Verify Virtual Machine Configuration**

Confirm that:

- Exactly one Virtual Machine exists.
- The VM name is `ubuntuvm-<inject key="deploymentid"/>`
- The VM operating system is **linux**.
- The VM provisioning state displays **Succeeded**.

> **Important:** Validation expects exactly six deployed resources in the resource group. Creating additional resources may cause validation to fail.

> After completing the task, click the **Validation** tab.

<validation step="62edf637-0ffb-4e67-9fc4-bad938dbdaa2" />

## **Evaluation Criteria**

Your submission will be evaluated based on:

**Task 1**
- Correct Azure sign-in.
- Correct subscription and tenant selection.
- Understanding of deployment requirements.

**Task 2**
- Review of the ARM template and parameter file.
- Verification of required template components.

**Task 3**
- Successful ARM deployment.
- Correct resource naming.
- Successful validation completion.

---

## **Completion Criteria**

You have successfully completed the assessment when:

- You signed in to the correct Azure environment.
- You reviewed the ARM template and parameter file.
- The ARM deployment completed successfully.
- The following resources exist in `labuser-rg`:
  - `lab-vnet`
  - `lab-nsg`
  - `VM-<inject key="DeploymentID"/>`
  - `VM-<inject key="DeploymentID"/>-nic`
  - `VM-<inject key="DeploymentID"/>-pip`
  - `VM-<inject key="DeploymentID"/>-osdisk`
- The Virtual Network contains exactly one subnet.
- The Virtual Machine is a Windows VM.
- No unexpected resources were created.

---

**You have successfully completed Exercise 01: Deploy Infrastructure Using ARM Template.**
