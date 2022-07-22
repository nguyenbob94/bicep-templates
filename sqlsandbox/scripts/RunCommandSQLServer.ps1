[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3

#Prevent prompt
Install-PackageProvider NuGet -Force -Confirm:$False
Set-PSRepository PSGallery -InstallationPolicy Trusted -Force

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install vscode -y
choco install git -y 
choco install dotnetfx -y
choco install googlechrome -y

Install-Module -Name SqlServer -Force -AllowClobber -Confirm:$false
Import-Module -Name SqlServer

