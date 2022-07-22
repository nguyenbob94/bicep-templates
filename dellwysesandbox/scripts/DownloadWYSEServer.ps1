params(
  [string]$username
)

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install googlechrome -y

#Sadly the part where PS creates a file doesn't appear to work with runCommand. Further investigation required.

#$urlInstaller = "https://dl.dell.com/FOLDER08443567M/1/WMS_3.6.1.exe"

#if(!$Username)
#{
#  $path = "$($env:userprofile)\Desktop"
#
#  New-Item -Path $path -ItemType File -Name "InstallNotes.txt" -Verbose
#  Add-Content -Value "$urlInstaller" -Path "$($Path)\InstallNotes.txt"
#}
#else
#{
#  $path = "C:\Users\$($Username)\Desktop\"
#  
#  New-Item -Path $path -ItemType File -Name "InstallNotes.txt"
#  Add-Content -Value "$urlInstaller" -Path "$path\InstallNotes.txt"
#}

# Disable IE Enhanced security
$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer
Start-Process -Name Explorer
