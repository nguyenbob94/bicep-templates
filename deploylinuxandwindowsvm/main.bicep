targetScope = 'resourceGroup'

param username string
@secure()
param password string
param location string

var vmInstances = [
  {
    vmName: 'win01'
    vmPublisher: 'MicrosoftWindowsDesktop'
    vmOffer: 'Windows-10'
    vmSku: 'win10-21h2-pro'
    vmVersion: 'latest'
  }
  {
    vmName: 'linux01'
    vmPublisher: 'Canonical'
    vmOffer: 'UbuntuServer'
    vmSku: '18.04-LTS'
    vmVersion: 'latest'
  }
]

//Resource params
// When looping modules, don't use arrays. Use object for iterations instead.
// If arrays are used, each loop will create an array for each object. Not what we want.
var vmCollection = [ for i in range(0, 2): {
  pubIPName: 'pubIP-0${i}'
  nicName: 'nic-0${i}'
  ifConfigName: 'ifConfig-0${i}'
  vmName: 'vm0${i}'
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg-vmdeployment'
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
        name: 'subnet-vmdeployment'
        properties: {
          addressPrefix: '10.13.1.0/24'
        }
      }
    ]
  }
}

module deployCluster './deployCluster.bicep' = [for (vm, i) in vmCollection : {
  //IMPORTANT: When looping a module, the deployment name must be unique per iteration.
  name: '${i}-deployModuleCluster'
  scope: resourceGroup()
  params: {
    location: location
    pubIPName: vm.pubIPName
    nicName: vm.nicName  
    ifConfigName: vm.ifConfigName
    vmName: vmInstances[i].vmName
    vmPublisher: vmInstances[i].vmPublisher
    vmOffer: vmInstances[i].vmOffer
    vmSku: vmInstances[i].vmSku
    vmVersion: vmInstances[i].vmVersion
    vmusername: username
    vmpassword: password
    nicNsgId: nsg.id
    vnetSubnetId: vnet.properties.subnets[0].id
  }
}]

output vmDetails array = [ for i in range(0, 2): {
  vmHostname: deployCluster[i].outputs.vmHostNameOutput
  pubIP: deployCluster[i].outputs.pubIPOutput
}]
