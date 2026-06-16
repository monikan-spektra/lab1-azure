# Exercise 01: Deploy Infrastructure Using ARM Template

### Duration: 90 Minutes

## Getting Started with the Lab

This lab is designed to demonstrate how organizations can deploy foundational Azure infrastructure using an Azure Resource Manager (ARM) template. In real-world enterprise environments, cloud operations teams are frequently required to provision virtual machines and networking resources in a consistent, repeatable, and automated manner. Using ARM templates ensures that resources are deployed according to defined standards and naming conventions, reducing manual effort and configuration drift.

In this lab, you will deploy a complete Azure networking and compute environment into a resource group by applying a provided ARM template. You will create a Virtual Network, Network Security Group, Public IP Address, Network Interface, and a Windows Virtual Machine. By the end of the lab, you will have a fully provisioned Azure environment that demonstrates infrastructure-as-code deployment practices commonly used by cloud administrators and operations engineers.

## Accessing Your Lab Environment

Once you're ready to dive in, your virtual machine and guide will be right at your fingertips within your web browser.

## Virtual Machine & Lab Guide

Your virtual machine is your workhorse throughout the workshop. The lab guide is your roadmap to success.

   ![](../images/vm.png)

## Exploring Your Lab Resources

To get a better understanding of your lab resources and credentials, navigate to the **Environment** tab.

   ![](../images/lab1-1.png)

## Utilizing the Split Window Feature

For convenience, you can open the lab guide in a separate window by selecting the **Split Window** button from the Top right corner.

   ![](../images/split.png)

## Managing Your Virtual Machine

Feel free to **Start, Restart,** or **Stop** your virtual machine as needed from the **Resources** tab. Your experience is in your hands!

   ![](../images/res.png)

## Lab Guide Zoom In/Zoom Out

To adjust the zoom level for the environment page, click the **A↕: 100%** icon located next to the timer in the lab environment.

   ![](../images/zoom.png)

## Lab Validation

After completing the task, hit the **Validate** button under the Validation tab integrated within your lab guide. If you receive a success message, you can proceed to the next task; if not, carefully read the error message and retry the step, following the instructions in the lab guide.

   ![](../images/valid.png)

## Let's Get Started with Azure Portal

1. On your **Lab VM**, click on the **Azure Portal** icon as shown below:

   ![](../images/azure.png)

1. On the **Sign in to Microsoft Azure** tab, you will see the login screen. Enter the following email/username, and click on **Next (2)**.

   * **Email/Username:** <inject key="AzureAdUserEmail"></inject> **(1)**

      ![](../images/signin.png)

1. Now enter the following password and click on **Sign in (2)**.

   * **Enter Temporary Access Pass:** <inject key="AzureAdUserPassword"></inject> **(1)**

      ![](../images/pass.png)

1. If prompted to **Stay signed in?**, click **"No"**.

   ![](../images/stay.png)

## Support Contact

The CloudLabs support team is available 24/7, 365 days a year, via email and live chat to ensure seamless assistance at any time. We offer dedicated support channels tailored specifically for both learners and instructors, ensuring that all your needs are promptly and efficiently addressed.

Learner Support Contacts:

- Email Support: labs-support@spektrasystems.com
- Live Chat Support: https://cloudlabs.ai/labs-support

Now, click on **Next >>** from the lower right corner to move on to the next page.

![](../images/next.png)
