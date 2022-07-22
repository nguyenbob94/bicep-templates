# Description

A template that uses index loops to deploy a Windows 10 VM onto Azure. The template will deploy the amount of VMs based on the number of instances specified onto the same subnet and then apply each of the VMS with NSGS and unique public IP Addresses. 

This eliminates the need to install Windows 10 type hypervisors (Vmware, Virtualbox) and having to though boot up and out-of-box set up. Instead you'll get one Windows 10 instance ready to go for sandboxing that can be connected through RDP.

## Prerequesites

First, you'll need a Azure account and a proper subscription. Secondly, make sure you have the Azure module installed on Powershell and Azure CLI. This will be used to install Bicep. For more information on Azure Bicep, read https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install

If you have met these prereqs, you're good to go.

## How it works

Run the `deploy.ps1` script. By default this will deploy one VM. Once the deployment is complete, an output of the public IP address for the VM. Optional parameters can be added to overwrite the default settings. These include

## Parameters

| Param         | Type   | Description                                                          |
|---------------|--------|----------------------------------------------------------------------|
| username      | string | Specify the username for the instances (Default: adminuser)          |
| password      | string | Specify the password for the instances                               |
| instanceCount | int    | Specify the number of instances to deploy                            |
| rgName        | string | Specify a custom Resource Group name. (Default: rg-win10deployment)  |
| location      | int    | Specify the region for deployed resources. (Default: AustraliaEast)  |
| Destroy       | bool   | Destroy the deployment                                               |

## Example usage

Run script through Powershell as follows

#### Deploy 1 VM
`.\deploy.ps1 -username adminuser -password Login123!` 

#### Deploy 2 VMs with custom username and password
`.\deploy.ps1 -username John -password Sm1Th123# -instanceCount 2`

#### Destroy the deployment
`.\deploy.ps1 -Destroy`

*Note*: Usernames "Admin" or "Root" cannot be used as they are not accepted by default through bicep.
