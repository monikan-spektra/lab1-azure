# Getting Started with the Lab

### Estimated Duration: 15 Minutes

## Getting Started with the Lab

Welcome to **Lab 1: Azure, PowerShell, Windows and Linux**.

In this hands-on lab, you will work in an Azure environment to deploy and manage infrastructure by using an ARM template, PowerShell, and Linux administration tools. Throughout the lab, you will create core Azure resources, work with both Ubuntu and Windows virtual machines, secure SSH access on Linux, configure a web server, and automate virtual machine lifecycle operations.

To access the Azure environment for this lab, sign in to the Azure portal at <https://portal.azure.com> by using the following credentials:

- **Username/Email:** `<inject key="AzureAdUserEmail"></inject>`
- **Password:** `<inject key="AzureAdUserPassword"></inject>`
- **Subscription:** `<inject key="SubscriptionID"></inject>`
- **Tenant:** `<inject key="TenantID"></inject>`

Your deployment identifier for this lab is **<inject key="DeploymentID" enableCopy="false"></inject>**. Use the exact resource names provided in each exercise because validations will check for those names.

## Overview

In this lab, you will complete Azure administration tasks across infrastructure deployment, Linux hardening, web server configuration, and PowerShell-based virtual machine management.

By the end of this lab, you will be able to:

- Deploy Azure resources by using an ARM template and parameter file.
- Provision and review Ubuntu and Windows virtual machines in Azure.
- Secure SSH access on an Ubuntu virtual machine.
- Configure Apache and validate HTTP access on Linux.
- Use Azure PowerShell Az module cmdlets to stop and start virtual machines.

## Important

> [!Important]
> - Use the **exact resource names** specified in the exercise instructions.
> - Complete tasks in the order provided because later exercises depend on earlier deployments and configuration.
> - Do not delete resources unless the instructions explicitly tell you to do so.
> - If a step requires command-line work, carefully verify the target subscription and resource names before you run commands.

## Access Information

You will use the Azure lab environment provided for this exercise.

1. Open a browser and go to <https://portal.azure.com>.
2. Sign in with:
   - **Username/Email:** `<inject key="AzureAdUserEmail"></inject>`
   - **Password:** `<inject key="AzureAdUserPassword"></inject>`
3. Confirm that the selected subscription is **`<inject key="SubscriptionID"></inject>`**.
4. If prompted, confirm that the tenant context is **`<inject key="TenantID"></inject>`**.

You may also use PowerShell during the lab for Azure administration tasks. When needed, ensure you are working against the correct Azure context before running commands.

## Exploring Your Lab Resources

This lab focuses on Azure infrastructure and administration workflows. Depending on the exercise, you may interact with the following resource types:

- Azure Resource Groups
- Virtual Network and Subnet resources
- Network Security Group (NSG) rules
- Ubuntu virtual machine for Linux administration tasks
- Windows virtual machine for Windows administration tasks
- ARM template and parameters file used for deployment
- Azure PowerShell tools for VM power operations

During the lab, review deployed resources in the Azure portal and verify that provisioning completes successfully before continuing.

> [!Note]
> If an exercise asks you to connect to the Ubuntu virtual machine, follow the instructions exactly for SSH access, key configuration, and service validation.

## Utilizing the Split Window Feature

To improve efficiency during the lab, you can use a split-screen layout.

- Keep the lab guide open in one window or browser tab.
- Keep the Azure portal open in another window or tab.
- If you are using PowerShell or an SSH session, place it beside the lab guide so you can follow steps while entering commands.

This setup makes it easier to reference instructions while you deploy resources, update configuration files, and validate your work.

## Managing Your Virtual Machine

Some exercises in this lab require you to work directly with virtual machines.

- Use the Azure portal to review VM status and networking details.
- Use the provided instructions to connect to the Ubuntu VM when Linux configuration tasks are required.
- Use Azure PowerShell Az module cmdlets when instructed to stop or start virtual machines.
- Wait for provisioning or power-state changes to complete before moving on to the next step.

> [!Tip]
> When managing virtual machines, always confirm that you are targeting the correct VM and resource group before making changes.

## Lab Validation

Validation is included to help confirm that required tasks were completed successfully.

- Run validations when instructed in the exercise pages.
- Validation checks may confirm deployment success, VM configuration, service availability, or expected Azure resource state.
- If a validation does not pass, review the related task carefully and correct the issue before continuing.

## Note

> [!Note]
> This is a challenge-style lab environment. Exact naming, correct configuration, and task order matter. Small differences in resource names or configuration settings can cause validation to fail.

## Support Contact

If you experience issues with the lab environment, access, or instructions, contact your lab proctor or the support channel provided for your training session.

When requesting help, be prepared to share:

- The lab name: **Lab 1: Azure, PowerShell, Windows and Linux**
- Your deployment identifier: **<inject key="DeploymentID" enableCopy="false"></inject>**
- A brief description of the problem you encountered

## Next

Once you are ready, proceed to **Exercise 01** and begin deploying the Azure infrastructure required for the rest of the lab.

## After publishing

> [!Note] These steps run **after** you push the template to CloudLabs — they verify CloudLabs can actually serve this lab guide to candidates.

- **Verify docs-proxy access:** open Templates → your template → **Lab Guide Settings** in <https://admin.cloudlabs.ai> and confirm CloudLabs can reach this repo via the docs proxy. If the repo is private, configure GitHub access at the template level.
- **Verify inline questions and inline validations:** sign in to <https://admin.cloudlabs.ai>, open your template, and walk through one full lab run to confirm every `<question>` and `<validation step="..."/>` renders correctly. Fix any that don't resolve.
