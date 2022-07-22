params(
  [string]$username
)

# By default Windows Server has limited TLS options for web invoke. Enable to download the file
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install vscode -y
choco install git -y 
choco install dotnetfx -y
choco install googlechrome -y

$url = "https://download.microsoft.com/download/D/A/1/DA1FDDB8-6DA8-4F50-B4D0-18019591E182/GatewayInstall.exe"

if(!$Username)
{
  $path = "$($env:userprofile)\Desktop\GatewayInstall.exe"


  Invoke-Webrequest -uri $url -Outfile $path
}
else
{
  $path = "C:\Users\$($Username)\Desktop\GatewayInstall.exe"
  Invoke-Webrequest -uri $url -Outfile $path
}
