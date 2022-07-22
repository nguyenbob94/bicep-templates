targetScope = 'resourceGroup'

var rgID = take((uniqueString(resourceGroup().id)),5)
var vnetName = 'vnet-${rgID}'
var subnetName = 'subnet-${rgID}'
var nsgName = 'nsg-${rgID}'
var nicName = 'nic-${rgID}'
var pubIPName = 'pubIP-${rgID}'


var runCommandName = 'commandVM-${rgID}'
var scriptContent = loadTextContent('./scripts/postdeploymentstuff.sh')

param location string
param vmName string
param vmUsername string
@secure()
@minLength(8)
param vmPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/20'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource pubIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: pubIPName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-nsgrule'
        properties: {
          access: 'Allow'
          description: 'Default rule for http, https and ssh'
          destinationAddressPrefix: '10.0.0.0/20'
          destinationPortRanges: [
            '22'
            '80'
            '443'
          ]
          direction: 'Inbound'
          priority: 1337
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'allow-ping'
        properties: {
          access: 'Allow'
          description: 'Allows ping to the nic'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 1338
          protocol: 'Icmp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          publicIPAddress: {
            id: pubIP.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource linuxVM 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '19.04'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
  }
}

// I've given up. This literally works whenever it wants to.
// Better off to use Azure pipelines for this in mass deployment
// For simple deployments like this, I am going to just run the script through the Invoke-AZVMRunCommand cmdlet
// Perhaps one day this gets improved.

//resource runCommandVM 'Microsoft.Compute/virtualMachines/runCommands@2021-07-01' = {
//  name: runCommandName
//  location: location
//  parent: linuxVM
//  properties: {
//    asyncExecution: false
//    parameters: [
//      {
//        // bash scripts do not require name. This is fine
//        name: vmUsername
//        value: vmUsername
//      }
//    ]
//    source: {
//      script: scriptContent
//    }
//    timeoutInSeconds: 120
//  }
//}

output vmPublicIPAddress string = pubIP.properties.ipAddress
output vmHostName string = linuxVM.properties.osProfile.computerName
output vmUserName string = linuxVM.properties.osProfile.adminUsername
