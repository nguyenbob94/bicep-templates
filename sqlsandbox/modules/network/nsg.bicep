param location string
param nsgName string
param nsgRuleName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: nsgRuleName
        properties: { 
          priority: 1337
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
    ]
  }
}

//NSG id output
output nsgID string = nsg.id
