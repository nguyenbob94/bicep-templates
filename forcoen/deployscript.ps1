param(
  [string]$vmUsername,
  [string]$vmPassword,
  [string]$vmName = "REDBULL02",
  [string]$RGName = "rg-linuxvm",
  [string]$Location = "eastus",
  [string]$BicepTemplatePath = ".\main.bicep",
  [string]$SHScriptPath = ".\scripts\postdeploymentstuff.sh",
  [switch]$Destroy
)

function DestroyRG
{
  if($RGName -eq "rg-linuxvm")
  {
    Remove-AZResourceGroup -Name $RGName -Force -Verbose
  }
  else
  {
    Write-Output "If a custom RG name was used during the initial deployment of this template, the script will not know which RG to destroy"
    (Get-AZResourceGroup).ResourceGroupName
    $DestroyChoice = Read-Host "Select and type in the RG Group name listed above you wish to destroy"
    
    Remove-AZResourceGroup -Name $DestroyChoice -Force -Verbose
  }
}

function DeployBicep
{
  $UnacceptedUsernames = @("admin","root")

  if($VMUsername -in $UnacceptedUsernames -or !$VMUsername)
  {
    do
    {
      $VMUsername = Read-Host "Provide username for the vm. 'root' and 'admin' are not accepted"
    
    } # What the hell Powershell? As if these don't work
      #Until (($VMUsername -ne "root") -or ($VMUsername -ne "admin")) 
      #Until ($VMUsername -ne "root" -or $VMUsername -ne "admin")
      # This works however
      Until ($VMUsername -notin $UnacceptedUsernames) 
  }

  if(!$VMPassword)
  {
    do
    {
      $securedPWString  = Read-Host -AsSecureString "Provide password for $VMUsername. Password must have a minimum of 8 characters"
    } Until($securedPWString.length -gt 8) 
  }
  else
  {
    $securedPWString = $VMPassword | ConvertTo-SecureString -AsPlainText -Force
  }

  New-AzResourceGroupDeployment `
  -Verbose `
  -Name $RGName `
  -ResourceGroupName $RGName `
  -Mode "Complete" `
  -Force `
  -TemplateFile $BicepTemplatePath `
  -Location $Location `
  -vmUserName $vmUsername `
  -vmPassword $securedPWString `
  -vmName $vmName

  # Sleep for 30 seconds to be safe before running invoke
  Start-Sleep 30

  Invoke-AzVMRunCommand `
  -ResourceGroupName $RGName `
  -VMName $vmName `
  -CommandId 'RunShellScript' `
  -ScriptPath $SHScriptPath `
  -Parameter @{"param1" = $vmUserName}

  exit
}    

if($Destroy)
{
  DestroyRG
  exit
}

$CheckIfRGExists = Get-AZResourceGroup -Name $RGName -ErrorAction Ignore

if($CheckIfRGExists)
{
  while(-1)
  {
    switch(Read-Host "The resource group $RGName exists. Do you want to overwrite it? '(Y/N)'")
    {
      Y { DeployBicep }
      N { Exit }
      default {}
    }
  }
}
else
{
  New-AZResourceGroup -Name $RGName -Location 'eastus'
  DeployBicep
}