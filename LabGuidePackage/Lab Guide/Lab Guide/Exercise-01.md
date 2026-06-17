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

### **Task 1: Deploy and Verify the Infrastructure**

Deploy the ARM template and verify that all required resources were provisioned successfully.

---

## **Detailed Instructions**

### **Task 1: Deploy and Verify the Infrastructure**

 **Step 1: Start a Custom Deployment**

1. In the Azure portal, search for: **Deploy a custom template**
2. Choose: **Build your own template in the editor**
3. Upload the provided ARM template.
4. Upload the parameter file when prompted.

**Step 2: Configure Deployment Details**

| Field | Value |
| Resource Group | `RG-01` |


- Review the deployment settings.
- Choose **Review + Create**, then select **Create**.

**Step 3: Wait for Deployment Completion**

Monitor the deployment until the status displays:

> **Your deployment is complete.**

**Step 4: Verify Required Resources**

Navigate to the resource group `RG-01` and confirm that the following resources exist:

| Resource Type | Expected Resource Name |
|---|---|
| Virtual Network | `lab-vnet` |
| Network Security Group | `lab-nsg` |
| Virtual Machine | ```text
ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>
``` |
| Network Interface | `ubuntuvm-<inject key="deploymentid" enableCopy="true"/>-nic` |
| Public IP Address | `ubuntuvm-<inject key="deploymentid" enableCopy="true"/>-pip` |
| Managed Disk | `ubuntuvm-<inject key="deploymentid" enableCopy="true"/>-osdisk` |

**Step 5: Verify Networking Configuration**

Confirm that:
ubuntuvm-<inject key="DeploymentID" enableCopy="true"/>

- Exactly one Virtual Network exists.
- The Virtual Network contains exactly one subnet.
- Exactly one Network Security Group exists.

**Step 6: Verify Virtual Machine Configuration**

Confirm that:

- Exactly one Virtual Machine exists.
- The VM name is `ubuntuvm-<inject key="deploymentid" enableCopy="true" />`
- The VM operating system is **linux**.
- The VM provisioning state displays **Succeeded**.

> **Important:** Validation expects exactly six deployed resources in the resource group. Creating additional resources may cause validation to fail.

> After completing the task, click the **Validation** tab.

<validation step="62edf637-0ffb-4e67-9fc4-bad938dbdaa2" />

## **Evaluation Criteria**

Your submission will be evaluated based on:

**Task 1**
- Successful ARM deployment.
- Correct resource naming.
- Successful validation completion.

---

## **Completion Criteria**

You have successfully completed the assessment when:

- You signed in to the correct Azure environment.
- You reviewed the ARM template and parameter file.
- The ARM deployment completed successfully.
- The following resources exist in `RG-01`:
  - `lab-vnet`
  - `lab-nsg`
  - `ubuntuvm-<inject key="deploymentid" enableCopy="true" />`
  - `ubuntuvm-<inject key="deploymentid" enableCopy="true" />-nic`
  - `ubuntuvm-<inject key="deploymentid" enableCopy="true" />-pip`
  - `ubuntuvm-<inject key="deploymentid" enableCopy="true" />-osdisk`
- The Virtual Network contains exactly one subnet.
- The Virtual Machine is a linux VM.
- No unexpected resources were created.

---

**You have successfully completed Exercise 01: Deploy Infrastructure Using ARM Template.**
