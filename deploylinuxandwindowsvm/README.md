# Description

Based on https://github.com/nguyenbob94/windows10sandbox. This is a template deploys 1 Windows 10 VM and one Kali Linux VM onto the same subnet. A unique public IP Address will be outputed for each of the VMs. 

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
| rgName        | string | Specify a custom Resource Group name. (Default: rg-win10deployment)  |
| location      | int    | Specify the region for deployed resources. (Default: AustraliaEast)  |
| Destroy       | bool   | Destroy the deployment                                               |

## Example usage

Run script through Powershell as follows

#### Deploy 1 VM
`.\deploy.ps1 -username adminuser -password Login123!` 

#### Destroy the deployment
`.\deploy.ps1 -Destroy`

*Note*: Usernames "Admin" or "Root" cannot be used as they are not accepted by default through bicep.
