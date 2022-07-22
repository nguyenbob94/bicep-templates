targetScope = 'subscription'

param defaultLabel string = 'mssqllab'
param vmName string = 'mssqlserver01'

// VM Detail params. Left blank intentionally as default details are passed through via Powershell Script
param vmAdminUser string

@minLength(8)
@secure()
param vmAdminPassword string

// ResourceGroup params. Left blank intentionally as default details are passed through via Powershell Script
param rgName string
param location string

// Networking params
param vNetName string = 'vnet-${defaultLabel}'
param vnetAddressPrefix string = '10.0.0.0/20'
param nsgName string = 'nsg-${defaultLabel}'
param nsgRuleName string = 'AllowInboundServices'
param pubIPName string = 'pubIP-${defaultLabel}'


var subnetArray = [
  {
    name: 'subnet-jumpbox'
    properties: {
      addressPrefix: '10.0.1.0/26'
    }
  }
  {
    name: 'subnet-sqlinfra'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]

var nicJump = {
  name: 'nic-${defaultLabel}01'
  location: location
  ipConfigName: 'ipConfig-01'
  subnetId: vnetIPModules.outputs.arrayOfSubnetIDs[0].resourceId
  pubIPId: vnetIPModules.outputs.publicIPAddressIDOutput
}


var nicArray = [
  {
    name: 'nic-${defaultLabel}02'
    location: location
    ipConfigName: 'ipConfig-02'
    subnetId: vnetIPModules.outputs.arrayOfSubnetIDs[1].resourceId
  }
  {
    name: 'nic-${defaultLabel}03'
    location: location
    ipConfigName: 'ipConfig-03'
    subnetId: vnetIPModules.outputs.arrayOfSubnetIDs[1].resourceId
  }
]

var vmArray = [
  {
    vmName: 'jumpbox01'
    vmUsername: vmAdminUser
    vmPassword: vmAdminPassword
    vmSize: 'Standard_B1s'
    imagePublisher: 'MicrosoftWindowsServer'
    imageOffer: 'WindowsServer'
    imageSku: '2022-datacenter'
    nicId: nicModules.outputs.nicIDJumpboxOutput
    pubIPId: vnetIPModules.outputs.publicIPAddressIDOutput
  }
  {
    vmName: vmName
    vmUsername: vmAdminUser
    vmPassword: vmAdminPassword
    vmSize: 'Standard_DS2_v2'
    imagePublisher: 'microsoftsqlserver'
    imageOffer: 'sql2019-ws2019'
    imageSku: 'sqldev-gen2'
    nicId: nicModules.outputs.nicIDOutput[0].resourceId
  }
  {
    vmName: 'opdgserver01'
    vmUsername: vmAdminUser
    vmPassword: vmAdminPassword
    vmSize: 'Standard_DS2_v2'
    imagePublisher: 'microsoftsqlserver'
    imageOffer: 'sql2019-ws2019'
    imageSku: 'sqldev-gen2'
    nicId: nicModules.outputs.nicIDOutput[1].resourceId
  }
]

resource rG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vnetIPModules './modules/network/vnetIP.bicep' = {
  name: 'deployVnetIPModules'
  scope: rG
  params: {
    location: location
    vNetName: vNetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetArray: subnetArray
    pubIPName: pubIPName
  }
}

module nsgModules './modules/network/nsg.bicep' = {
  name: 'deployNsgModules'
  scope: rG
  params: {
    nsgName: nsgName
    location: location
    nsgRuleName: nsgRuleName
  }
}

module nicModules './modules/network/nic.bicep' = {
  name: 'deployNicModules'
  scope: rG
  params: {
    nsgID: nsgModules.outputs.nsgID
    nicJump: nicJump
    nicArray: nicArray
  }
}

module vmModules './modules/compute/vm.bicep' = {
  name: 'deployVMModules'
  scope: rG
  params: {
    location: location
    vmArray: vmArray
  }
}

output vmLocalCredentials object = {
  Username: vmAdminUser
  Password: 'IS_SET'
}

output jumpboxVMDetails object = {
  jumpboxServerName: vmModules.outputs.arrayVMNameOutput[0].vmName
  ExternalIP: vnetIPModules.outputs.publicIPAddressOutput
}

