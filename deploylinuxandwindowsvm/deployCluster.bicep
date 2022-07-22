// For a module subjected to looping. There should be no hard coded loops here. All the looping are all done within the parent module (main.bicep)

param location string
param vmusername string
@secure()
param vmpassword string
param nicNsgId string
param vnetSubnetId string

//Resource names for looping mechanism from main.bicep
//param resourceArray array

param pubIPName string
param nicName string
param ifConfigName string

param vmName string
param vmPublisher string
param vmOffer string
param vmSku string
param vmVersion string


resource pubIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: pubIPName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ifConfigName
        properties: {
          publicIPAddress: {
            id: pubIP.id
          }
          subnet: {
            id: vnetSubnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nicNsgId
    }
  }
}

resource vms 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: vmPublisher
        offer: vmOffer
        sku: vmSku
        version: vmVersion
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmusername
      adminPassword: vmpassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output vmHostNameOutput string = vms.name
output pubIPOutput string = pubIP.properties.ipAddress
