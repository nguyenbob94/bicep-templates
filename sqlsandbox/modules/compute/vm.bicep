param location string
param vmArray array

//To complicated to iterate scripts per VM. To be hardcoded in this module instead
//End of the day IaC is made to uncomplicate things. Not add more work
param runCommandNameSQL string = 'runCommandName-SQL'
param runCommandNameOPDG string = 'runCommandName-OPDG'
var scriptContentSQLServer = loadTextContent('../../scripts/RunCommandSQLServer.ps1', 'utf-8')
var scriptContentOPDGServer = loadTextContent('../../scripts/RunCommandOPDGServer.ps1', 'utf-8')


resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = [ for v in vmArray: {
  name: v.vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: v.vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: v.imagePublisher
        offer: v.imageOffer
        sku: v.imageSku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: v.nicId
        }
      ]
    }
    osProfile: {
      computerName: v.vmName
      adminUsername: v.vmUsername
      adminPassword: v.vmPassword
    }
  }
}]

resource mssql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2021-11-01-preview' = {
  name: vmArray[1].vmName
  location: location
  properties: {
    serverConfigurationsManagementSettings: {
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: true
      }
      sqlConnectivityUpdateSettings: {
        connectivityType: 'PRIVATE'
        port: 1433
        sqlAuthUpdatePassword: vmArray[1].vmUsername
        sqlAuthUpdateUserName: vmArray[1].vmPassword
      }
    }
    sqlServerLicenseType: 'PAYG'
    sqlManagement: 'Full'
    virtualMachineResourceId: vm[1].id
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: vmArray[1].vmPassword
      clusterOperatorAccountPassword: vmArray[1].vmPassword
      sqlServiceAccountPassword: vmArray[1].vmPassword
    }
  }
}

//Inject script into VM index 1
resource runCommandSQL 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: runCommandNameSQL
  location: location
  parent: vm[1]
  properties: {
    asyncExecution: false
    source: {
      script: scriptContentSQLServer
    }
    timeoutInSeconds: 30
  }
}

//Inject script into VM index 2
resource runCommandOPDG 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: runCommandNameOPDG
  location: location
  parent: vm[2]
  properties: {
    asyncExecution: false
    source: {
      script: scriptContentOPDGServer
    }
    timeoutInSeconds: 30
  }
}



output arrayVMNameOutput array = [ for (vmName, i) in vmArray: {
 vmName: vm[i].name
 vmIndex: vm[i]
}]
