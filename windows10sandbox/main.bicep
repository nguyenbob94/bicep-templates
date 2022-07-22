targetScope = 'resourceGroup'

param username string
@secure()
param password string
param location string
param instanceCount int

//Resource params
// When looping modules, don't use arrays. Use object for iterations instead.
// If arrays are used, each loop will create an array for each object. Not what we want.
var vmCollection = [ for i in range(0, instanceCount): {
  pubIPName: 'pubIP-0${i}'
  nicName: 'nic-0${i}'
  ifConfigName: 'ifConfig-0${i}'
  vmName: 'vm0${i}'
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg-win10deployment'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-RDP'
        properties: {
          priority: 699
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationPortRanges: [
            '3389'
          ]
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allow-Ping'
        properties: {
          priority: 700
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Icmp'
          destinationPortRange: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }  
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'vnet-win10deployment'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.13.1.0/24'
      ]
    }
    subnets: [
      {
        name: 'subnet-win10deployment'
        properties: {
          addressPrefix: '10.13.1.0/24'
        }
      }
    ]
  }
}

module deployCluster './deployCluster.bicep' = [for (vm, i) in vmCollection: {
  //IMPORTANT: When looping a module, the deployment name must be unique per iteration.
  name: '${i}-deployModuleCluster'
  scope: resourceGroup()
  params: {
    location: location
    pubIPName: vm.pubIPName
    nicName: vm.nicName  
    ifConfigName: vm.ifConfigName
    vmName: vm.vmName
    vmusername: username
    vmpassword: password
    nicNsgId: nsg.id
    vnetSubnetId: vnet.properties.subnets[0].id
  }
}]

output vmDetails array = [ for i in range(0, instanceCount): {
  vmHostname: deployCluster[i].outputs.vmHostNameOutput
  pubIP: deployCluster[i].outputs.pubIPOutput
}]
