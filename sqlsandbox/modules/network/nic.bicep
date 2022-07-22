param nicJump object
param nicArray array 
param nsgID string

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = [ for i in nicArray: {
  name: i.name
  location: i.location
  properties: {
    ipConfigurations: [
      {
        name: i.ipConfigName
        properties: {
          subnet: {
            id: i.subnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgID
    }
  }
}]

resource nicJumpbox 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicJump.name
  location: nicJump.location
  properties: {
    ipConfigurations: [
      {
        name: nicJump.ipConfigName
        properties: {
          subnet: {
            id: nicJump.subnetId
          }
          publicIPAddress: {
            id: nicJump.pubIPId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgID
    }

  }
}


output nicIDJumpboxOutput string = nicJumpbox.id

output nicIDOutput array = [ for (id, i) in nicArray: {
  resourceId: nic[i].id
}]
