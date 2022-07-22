param vmName string
param location string
param vmProperties object
param vmUsername string
param scriptContent string
param runCommandPS string

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: vmProperties
}

resource runCommand 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: runCommandPS
  parent: vm
  location: location
  properties: {
    asyncExecution: false
    parameters: [
      {
        name: 'username'
        value: vmUsername
      }
    ]
    source: {
      script: scriptContent
    }
  }
}

output vmNameOutput string = vm.name
