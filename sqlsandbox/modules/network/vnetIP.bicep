param location string
param vNetName string
param vnetAddressPrefix string
param subnetArray array
param pubIPName string

resource vNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: subnetArray
  }  
}

resource pubIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: pubIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
  }
}

//Output subnet id from vnet resource
output arrayOfSubnetIDs array = [ for (id, i) in subnetArray: {
  resourceId: vNet.properties.subnets[i].id
}]

//Output public IP address id from pubIP resource
output publicIPAddressIDOutput string = pubIP.id
output publicIPAddressOutput string = pubIP.properties.ipAddress
