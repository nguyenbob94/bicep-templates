param vNetName string 
param location string
param vnetAddressPrefix string
param subnetObject object
param pubIPName string
param nsgName string 
param nsgRule object
param nicName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix 
      ]
    }
    subnets: [
      subnetObject
    ]
  }
}

resource pubIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: pubIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Basic'
  }  
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      nsgRule
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: pubIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
        id: nsg.id
    }
    
  }
}

output nicIDForVM string = nic.id
output pubIPforVM string = pubIP.properties.ipAddress
