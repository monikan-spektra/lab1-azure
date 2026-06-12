# Solution Guide

## Overview

This lab is split into four scenarios:

1. **Scenario 1**: Deploy base Azure infrastructure with ARM.
2. **Scenario 2**: Deploy and secure an Ubuntu VM.
3. **Scenario 3**: Configure Ubuntu as a web server.
4. **Scenario 4**: Automate Azure VM start/stop operations with PowerShell.

The updated plan removes the earlier assumption that Ubuntu is deployed by ARM. The ARM deployment now provisions only the shared network and the Windows VM. Learners deploy the Ubuntu VM later, during Scenario 2.

Use the exact resource names defined in the lab guide. Validation is name-sensitive and region-sensitive.

---

## Scenario 1: Deploy Base Azure Infrastructure by Using ARM Template

### Expected end-state

The ARM deployment creates only the following base resources:

- one virtual network
- one subnet
- one network security group
- one Windows virtual machine

The Windows VM must be provisioned successfully and associated with the shared network.

### Full credit

- ARM template and parameter file deploy without errors.
- VNet, subnet, NSG, and Windows VM exist in the correct resource group and region.
- VM provisioning state is `Succeeded`.
- NSG is associated to the correct subnet or NIC, as designed in the template.

### Partial credit

- Template deploys but one or more resources are missing.
- VM exists but is in a failed or stopped provisioning state.
- Network resources exist in the wrong region or resource group.
- The template includes stale Ubuntu resources that are not part of the current plan.

### Common pitfalls

- Deploying to the wrong Azure region.
- Using a different resource group than the lab expects.
- Leaving obsolete Ubuntu parameters or resources in the ARM template.
- Missing a system-assigned identity on the Windows VM if the template or validation expects it.
- Hard-coding admin credentials instead of using the provided parameter placeholders.
- Soft-deleted resources from a prior run blocking recreation.

### Manual verification

```bash
az group show -n <resource group>
az network vnet show -g <resource group> -n <vnet name>
az network nsg show -g <resource group> -n <nsg name>
az vm show -g <resource group> -n <windows vm name> --show-details
```

```powershell
Get-AzResourceGroup -Name <resource group>
Get-AzVirtualNetwork -ResourceGroupName <resource group> -Name <vnet name>
Get-AzNetworkSecurityGroup -ResourceGroupName <resource group> -Name <nsg name>
Get-AzVM -ResourceGroupName <resource group> -Name <windows vm name> -Status
```

---

## Scenario 2: Deploy and Secure Ubuntu VM

### Expected end-state

Learners manually deploy an Ubuntu VM into the provided Azure network, then harden SSH access:

- Ubuntu VM is created in the lab subscription and region.
- VM is attached to the existing VNet/subnet from Scenario 1.
- Root SSH login is disabled.
- Key-based SSH authentication is enforced.
- SSH daemon configuration validates cleanly.
- SSH service restarts successfully after configuration changes.

### Full credit

- Ubuntu VM exists and is reachable.
- SSH config includes `PermitRootLogin no`.
- Password authentication is disabled or the lab’s required key-only posture is met.
- `sshd -t` succeeds before restart.
- SSH service is restarted and remains healthy.

### Partial credit

- VM is deployed but not connected to the correct subnet.
- SSH hardening is applied but config validation was not performed.
- Root login remains enabled.
- Key-based auth is not enforced.
- SSH service is restarted but subsequent login fails due to broken configuration.

### Common pitfalls

- Reusing the ARM deployment path for Ubuntu; the latest plan expects manual deployment in Scenario 2.
- Selecting the wrong VNet or subnet.
- Forgetting to attach a public IP if the lab access model requires direct SSH.
- Editing `/etc/ssh/sshd_config` but not restarting `sshd`.
- Locking out access by disabling password auth before confirming the key is installed in `~/.ssh/authorized_keys`.
- Misspelling `PermitRootLogin no` or leaving duplicate directives in `sshd_config`.

### Manual verification

```bash
az vm show -g <resource group> -n <ubuntu vm name> --show-details
```

```bash
sudo grep -E '^(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config
sudo sshd -t
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
```

---

## Scenario 3: Configure Ubuntu VM as a Web Server

### Expected end-state

The Ubuntu VM serves the default Apache web page over HTTP.

- HTTP access is allowed by the required NSG rule or equivalent network control.
- Apache is installed.
- Apache is started and enabled.
- The default web page is reachable from the validation path.

### Full credit

- HTTP inbound rule exists and targets the correct NIC or subnet.
- `apache2` is installed successfully.
- `apache2` service is active.
- The default Apache page returns content over port 80.

### Partial credit

- Apache is installed but not running.
- The service is running but HTTP is blocked by NSG.
- The rule exists but targets the wrong priority, source, or destination.
- The page loads locally but not externally.

### Common pitfalls

- Adding the NSG rule to the wrong NSG or wrong NIC.
- Using the wrong service name on Ubuntu (`apache2`, not `httpd`).
- Forgetting `sudo apt update` before installation.
- Testing only on localhost instead of the validation endpoint.
- Network security rule priority conflicts with the default deny rule.

### Manual verification

```bash
az network nsg rule list -g <resource group> --nsg-name <nsg name> -o table
```

```bash
sudo systemctl status apache2 --no-pager
curl -I http://localhost
curl http://localhost
```

---

## Scenario 4: Automate Azure VM Start and Stop Operations

### Expected end-state

Learners use Az PowerShell to stop and start the required Azure VMs and verify power states.

- At least one VM is stopped/deallocated.
- Required VM(s) are started again.
- Power state is confirmed after each operation.

### Full credit

- Correct subscription context is selected.
- `Stop-AzVM` is used with the correct resource group and VM name.
- `Start-AzVM` is used afterward.
- `Get-AzVM -Status` confirms expected states, typically `VM deallocated` and then `VM running`.

### Partial credit

- Commands run against the wrong subscription or resource group.
- VM transitions are initiated but not verified.
- VM is stopped but not deallocated when the task expects deallocation.
- Learner stops the wrong VM.

### Common pitfalls

- Not calling `Set-AzContext` before running VM commands.
- Assuming `Stop-AzVM` always deallocates in every context or script path.
- RBAC not yet propagated for a newly assigned identity or role.
- Confusing the Windows VM from Scenario 1 with the Ubuntu VM from Scenario 2.
- Not waiting long enough for the power-state transition to complete.

### Manual verification

```powershell
Get-AzContext
Get-AzVM -ResourceGroupName <resource group> -Name <vm name> -Status
Stop-AzVM -ResourceGroupName <resource group> -Name <vm name> -Force
Get-AzVM -ResourceGroupName <resource group> -Name <vm name> -Status
Start-AzVM -ResourceGroupName <resource group> -Name <vm name>
Get-AzVM -ResourceGroupName <resource group> -Name <vm name> -Status
```

---

## Instructor Notes

- The ARM template should be limited to the shared foundation resources and the Windows VM only.
- Do not expect Ubuntu resources to exist until Scenario 2 is completed.
- If validation fails after a correct deployment, check for stale resources, wrong region, or prior soft-deleted objects.
- Keep naming aligned with the lab guide exactly; validation is designed to be strict.
- For network-related failures, confirm the subnet association, NSG association, and public/private IP expectations before debugging the guest OS.
