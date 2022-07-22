# What's this?

I've written this for a friend but also as an excuse to practice and explore injecting scripts into VMs deployed via bicep.

This is a bicep template that deploys the a single Linux VM on Azure and preconfigures it with a post deployment script to install `nmap`, `openvpn` and `p7zip` for the purpose of... _uhhhhh, Snooping ports and pentesting stuff?_

#### Edit 1

I've decided to scrap the idea of using runCommands resource to call the bash script for the deployment. It's awfully inconsistent and 90% of the time it doesn't work. 40% of the time be will deploy the commands but miss several others. 10% it wont work at all. In subsititute, I've ended up just using Invoke-AZVMRunCommand on Powershell after the bicep deployment. This is feasible in small deployments like this. With large deployments, I'm probably better off using CI/CD pipelines.

#### Edit 2

So it seems like there's a race factor between the VM booting up after deployment vs the `Invoke-AZVMRunCommand` cmdlet. I wonder if that applies to bicep and ARM templates? This might explain the inconsistencies in commands being run. I could be wrong here but atleast with Powershell, you can add Start-Sleep to delay to command from running for a bit before the VM gets itself ready.

## Prerequesites

Make sure you have your Powershell ExecutionPolicy configured to allow running scripts. On Powershell admin, run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`

* First you'll need the Powershell 7 installed: https://github.com/PowerShell/PowerShell/releases/download/v7.2.2/PowerShell-7.2.2-win-x64.msi
* Secondly, you'll need to download and install Azure CLI in order to install Bicep CLI: https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install. Optionally, Bicep can be installed through Chocolatey  `choco install bicep -y`
* Thirdly, you'll need an Azure account and a valid subscription to authententicate with Azure CLI / Azure module on Powershell

## How does it work?

The bicep template deploys on a Resource Group level through running the `deployscript.ps1` script. This script intially creates the Resource Group before initally calling `main.bicep` to deploy the Linux VM and its dependencies (Network resources).

Values such as names of Azure resources are passed through with parameters from the Powershell script, and onto the Bicep file. Such default values like Resource VM name, location info are hardcoded onto the script. However, they can be overwritten if defined. Refer to the parameter table below for information on what parameters are available on the script.

<del>In addition the bicep file will also call upon the `postdeploymentstuff.sh` script once the VM is deployed, using the `'Microsoft.Compute/virtualMachines/runCommands'` resource and the `loadTextContent()` function. The bash script installs the required packages and download files in the VM. This is a much desired method as opposed to dealing with custom script extensions, specifically on Linux VMs.</del>




## Script parameters

| Param             | Type   | FixedValue   | Description                                                                                                                                                                                                     |
|-------------------|--------|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| vmUserName        | String | -            | A username for the local account of the VM. If undefined, the script will prompt for an input                                                                                                                   |
| vmPassword        | String | -            | A password string for the username above. String will get converted to secureString() and passed to variable $securedPWString. If undefined the script will prompt an input directly to $securedPWString |
| vmName            | String | REDBULL01    | The hostname for the VM. Predefined with a fixed value but can be overwritten upon calling param.                                                                                                               |
| RGName            | String | rg-linuxvm   | The default name of the resource group. Recommend to leave this as is for the Destroy param to work.                                                                                                            |
| Location          | String | eastus       | The value of the region for the deployment. Can be overwritten with a different region                                                                                                                          |
| BicepTemplatePath | String | ./main.bicep | The path the the bicep file. This is predefined already so there's no need to change it                                                                                                                         |
| SHScriptPath      | String | ./scripts/bashfile | Defines the bash script to inject into the VM after deployment |
| Destroy           | Switch | -            | Destroys the resource group and all its resources, only works if the resource group named by the default value.                                                                                                 |

Required parameters include `vmUsername` and `vmPassword` .

## How to use it

#### Example usage

Run script with no params and follow the prompts: `.\deployscript.ps1`

Alternatively run scripts and define the parameters from the table above" `.\deployscript.ps1 -vmUsername adminuser -Location AustraliaEast`


