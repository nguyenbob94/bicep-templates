//Boot diagmostics
//Autoshutdown

targetScope = 'subscription'

param defaultLabel string = 'dellwyselab'
param vmName string = 'vmdellwyselab01'

param vmUsername string

@minLength(8)
@secure()
param vmAdminPassword string

// ResourceGroup params. Left blank intentionally as default details are passed through via Powershell Script
param rgName string
param location string

// Networking params
param vNetName string = 'vnet-${defaultLabel}'
param vnetAddressPrefix string = '10.10.0.0/16'
param subnetAddressPrefix string = '10.10.0.0/24'
param nsgName string = 'nsg-${defaultLabel}'
param pubIPName string = 'pubIP-${defaultLabel}'
param nicName string = 'nic-${defaultLabel}'

var subnetObject = {
  name: 'subnet01'
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

var nsgRule =  {
  name: 'AllowInbound'
  properties: { 
    priority: 1337
    access: 'Allow'
    direction: 'Inbound'
    protocol: 'Tcp'
    destinationPortRanges: [
      '80'
      '443'
      '3389'
    ]
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
}

var vmProperties = {
  hardwareProfile: {
    vmSize: 'Standard_F4s_v2'
  }
  storageProfile: {
    osDisk: {
      createOption: 'FromImage'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter'
      version: 'latest'
    }
  }
  networkProfile: {
    networkInterfaces: [
      {
        id: networkModules.outputs.nicIDForVM 
      }
    ]
  }
  osProfile: {
    computerName: vmName
    adminUsername: vmUsername
    adminPassword: vmAdminPassword
  }
}

var scriptContent = loadTextContent('./scripts/DownloadWYSEServer.ps1', 'utf-8')
var runCommandPS = 'runCommandName-${defaultLabel}-WYSE'

resource rG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module networkModules './modules/network.bicep' = {
  name: 'deployNetworkModules'
  scope: rG
  params: {
    //Vnet components
    location: location
    vNetName: vNetName
    vnetAddressPrefix: vnetAddressPrefix 
    subnetObject: subnetObject
    //Public IP address compoments
    pubIPName: pubIPName
    //NSG components
    nsgName: nsgName
    nsgRule: nsgRule
    //Nic components
    nicName: nicName
    //VM components
  }
}

module computeModules './modules/compute.bicep' = {
  name: 'deployComputeModules'
  scope: rG
  params: {
    vmName: vmName
    location: location
    vmProperties: vmProperties
    //VM username is the same value as what is used in the vmProperties for the host name. This specific variable is used for runCommand
    vmUsername: vmUsername
    scriptContent: scriptContent 
    runCommandPS: runCommandPS
  }
}

output publicIPOutputForVM string = networkModules.outputs.pubIPforVM
output vmServerNameOutout string = computeModules.outputs.vmNameOutput
