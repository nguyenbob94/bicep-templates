param location string
param nicid string
param vmHostName string 
param vmAdminUser string
param runCommandNameOPDG string
param scriptContent string

@minLength(8)
@secure()
param vmAdminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmHostName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicid
        }
      ]
    }
    osProfile: {
      computerName: vmHostName
      adminUsername: vmAdminUser
      adminPassword: vmAdminPassword
    }
  }
}

// Not working just yet. Will need to investigate
resource runCommand 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: runCommandNameOPDG
  parent: vm
  location: location
  properties: {
    asyncExecution: false
    parameters: [
      {
        name: 'username'
        value: vmAdminUser
      }
    ]
    source: {
      script: scriptContent
    }
  }
}
