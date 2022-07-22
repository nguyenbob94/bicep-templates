param(
  [string]$vmAdminUser = "adminuser",
  [string]$vmAdminPassword,
  [string]$rgName = "rg-mssqllab",
  [string]$DeploymentLocation = "AustraliaEast",
  [string]$TemplateFile = ".\main.bicep",
  [switch]$Destroy

)

function DeployBicepTemplate
{
  if($Destroy -eq $true)
  {
    Remove-AzResourceGroup -Name $rgName -Force -Verbose
    exit
  }

  $CheckIfTemplateFileExist = Test-Path $TemplateFile

  if($CheckIfTemplateFileExist -eq $True)
  {
    if(!$vmAdminPassword)
    {
      $SecuredPWString = Read-Host "Enter admin password for $vmHostName" -AsSecureString
    }
    else
    {
      $SecuredPWString = $vmAdminPassword | ConvertTo-SecureString -AsPlainText -Force
    }

    New-AzSubscriptionDeployment -Verbose `
    -TemplateFile $TemplateFile `
    -Location $DeploymentLocation `
    -rgName $rgName `
    -vmAdminUser $vmAdminUser `
    -vmAdminPassword $SecuredPWString `
    -LocationfromTemplate $DeploymentLocation 

   }
   else
   {
     Write-Output "Template $TemplateFile does not exist. Please specify approprate file path of the bicep template with the -TemplateFile param"
     exit
   }
  
  exit
}


# Check if Azure module is installed on Powershell before running script
$CheckPSModule = (Get-InstalledModule -Name az).Name

if($CheckPSModule -eq "az")
{
  # Check Azure session on Powershell before running script
  $CheckAzSession = Get-AzAccessToken -ErrorAction Ignore

  # If session is available, start deployment. If not, call the Login-AZAccount cmdlet to authenticate with Azure admin account
  if($CheckAzSession)
  {
    Write-Output "Azure session found on Powershell"
    Get-AZAccessToken
    DeployBicepTemplate
  }
  else
  {
    Logout-AZAccount
    Login-AZAccount
    DeployBicepTemplate
  }
}
else
{
  Write-Output "Az Powershell Module is not found, imported or installed. Please install the az Powershell module then run this script again"
  Write-Output "Run the following cmdlet to install: Install-Module -Name az -Scope CurrentUser -AllowClobber"
  exit
}

