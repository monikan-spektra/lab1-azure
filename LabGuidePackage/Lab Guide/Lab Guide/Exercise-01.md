# Exercise 01: Deploy infrastructure using ARM template

## Lab Overview

In this exercise, you will deploy the base Azure infrastructure required for the remaining lab scenarios. You will sign in to Azure, review the deployment requirements, inspect the ARM template and parameter file, and then deploy and verify the core resources.

## Scenario

You have recently joined a cloud operations team as an Azure infrastructure engineer.

Your manager has asked you to deploy the required base Azure environment by using an ARM template so that both Windows and Linux administration tasks can be completed later in the lab. You must review the deployment requirements, validate the template inputs, and confirm that the infrastructure deploys successfully.

## Solution

To complete this scenario, you will sign in to the Azure portal by using the provided lab credentials, review the ARM deployment files, and deploy the base infrastructure into the assigned subscription. The deployment will create the foundational resources needed for later exercises, including a virtual network, subnet, network security resources, and a Windows virtual machine.

## Learning Objectives

After completing this exercise, you will be able to:

- Sign in to Azure and confirm the correct lab subscription context.
- Review the ARM template and parameter file used for deployment.
- Deploy base Azure infrastructure by using an ARM template.
- Verify that the required network and virtual machine resources were provisioned successfully.

## Environment Information

This exercise uses the Azure lab environment, the Azure portal, and ARM deployment files provided as part of the lab.

Use the following credentials to sign in to Azure:

- Username: `<inject key="AzureAdUserEmail"></inject>`
- Password: `<inject key="AzureAdUserPassword"></inject>`
- Subscription: `<inject key="SubscriptionID"></inject>`
- Tenant: `<inject key="TenantID"></inject>`

Use the deployment identifier **<inject key="DeploymentID" enableCopy="false"/>** whenever you are asked to reference the lab deployment.

> [!Important]
> Use the exact resource names defined in the deployment files. Validation checks are based on those names.

## Assessment Objectives

### Task 1: Sign in to Azure and review the deployment requirements

- Sign in to Azure and confirm the correct subscription context.
- Review the required resource names and deployment files.

### Task 2: Create or review the ARM template and parameter file

- Create or review a single ARM template file and parameter file.
- Confirm the template will deploy one virtual network, one subnet, one network security group, and one Windows virtual machine.

### Task 3: Deploy and verify the base infrastructure

- Deploy the ARM template.
- Wait for the deployment to complete.
- Verify that only the required base resources were created successfully.

## Detailed Instructions

### Task 1: Sign in to Azure and review the deployment requirements

1. Open a browser and go to <https://portal.azure.com>.
2. Sign in with the following credentials:
   - Username: `<inject key="AzureAdUserEmail"></inject>`
   - Password: `<inject key="AzureAdUserPassword"></inject>`
3. After signing in, confirm that you are working in subscription `<inject key="SubscriptionID"></inject>` and tenant `<inject key="TenantID"></inject>`.
4. Review the deployment requirements for this scenario, including the ARM template, parameter file, and the expected base resources.
5. Make a note of the deployment identifier **<inject key="DeploymentID" enableCopy="false"/>** for use during lab activities.

### Task 2: Create or review the ARM template and parameter file

1. Open the provided ARM template file and parameter file for this lab.
2. Review the template structure and confirm it defines the required Azure resources.
3. Verify that the deployment includes the following components:
   - One virtual network
   - One subnet
   - One network security resource
   - One Windows virtual machine
4. Review the parameter values that will be used during deployment.
5. Ensure the files are ready to be deployed without unnecessary changes.

### Task 3: Deploy and verify the base infrastructure

1. In the Azure portal, start a custom deployment by using the provided ARM template and parameter file.
2. Deploy the template to the assigned subscription and resource group for this lab.
3. Wait for the deployment to complete successfully.
4. Review the deployment details and confirm that the required resources were created.
5. Verify that the virtual network, subnet, network security resources, and Windows virtual machine show a successful provisioning state.

<validation step="62edf637-0ffb-4e67-9fc4-bad938dbdaa2"/>

## Evaluation Criteria

Your work will be evaluated on your ability to:

- Sign in to the correct Azure lab environment.
- Review and understand the ARM template and parameter file.
- Deploy the base infrastructure successfully.
- Verify that the expected resources were provisioned correctly.

## Completion Criteria

You have successfully completed this exercise when:

- You signed in to Azure by using `<inject key="AzureAdUserEmail"></inject>`.
- You reviewed the ARM template and parameter file.
- The ARM deployment completed successfully.
- The virtual network, subnet, network security resources, and Windows virtual machine were provisioned and verified.

**Completed Exercise 01: Deploy infrastructure using ARM template**
