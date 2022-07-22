targetScope = 'resourceGroup'

param instanceCount int = 5

var vmArray = [ for i in range(0, instanceCount): {
  pubIPName: 'pubIP-0${i}'
  nicName: 'nic-0${i}'
  ifConfigName: 'ifConfig-0${i}'
  vmName: 'vm0${i}'
}]

output arrayResult array = vmArray
