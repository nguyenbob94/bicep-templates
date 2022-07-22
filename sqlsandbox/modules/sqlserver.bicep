param location string
param nicid string
param vmHostName string 
param vmAdminUser string
param runCommandNameSQL string
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
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'sqldev-gen2'
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

resource mssql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2021-11-01-preview' = {
  name: vmHostName
  location: location
  properties: {
    serverConfigurationsManagementSettings: {
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: true
      }
      sqlConnectivityUpdateSettings: {
        connectivityType: 'PRIVATE'
        port: 1433
        sqlAuthUpdatePassword: vmAdminPassword
        sqlAuthUpdateUserName: vmAdminUser
      }
    }
    sqlServerLicenseType: 'PAYG'
    sqlManagement: 'Full'
    virtualMachineResourceId: vm.id
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: vmAdminPassword
      clusterOperatorAccountPassword: vmAdminPassword
      sqlServiceAccountPassword: vmAdminPassword
    }
  }
}

resource runCommand 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: runCommandNameSQL
  parent: vm
  location: location
  properties: {
    asyncExecution: false
    parameters: [
      {
        name: 'Hostname'
        value: vmHostName
      }
    ]
    source: {
      script: scriptContent
    }
  }
}

// Used for both the sql server and the OPDG server
output outputVmName string = vm.name
output outputVmUsername string = vm.properties.osProfile.adminUsername
