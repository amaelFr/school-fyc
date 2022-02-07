$tempFolder="C:\Users\vagrant\AppData\Local\Temp\"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile "${tempFolder}Sysmon.zip"

Expand-Archive -path "${tempFolder}Sysmon.zip" -destinationpath "${tempFolder}Sysmon" -Force

Write-Host "Install sysmon"

C:\Users\vagrant\AppData\Local\Temp\Sysmon\Sysmon64.exe -i -accepteula -h md5,sha256,imphash -l -n

Write-Host "Installed sysmon"


$winlogbeatBaseConf="C:\Program Files\Winlogbeat\"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.6.2-windows-x86_64.zip -OutFile "${tempFolder}winlogbeat.zip"

Expand-Archive -path "${tempFolder}winlogbeat.zip" -destinationpath "${tempFolder}winlogbeat" -Force

New-Item -Path "C:\Program Files\" -Name "Winlogbeat" -ItemType "directory"

Copy-Item "${tempFolder}winlogbeat\winlogbeat-7.6.2-windows-x86_64\*" -Destination "$winlogbeatBaseConf" -Recurse

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Cyb3rWard0g/HELK/master/configs/winlogbeat/winlogbeat.yml -OutFile "${winlogbeatBaseConf}winlogbeat.yml"

((Get-Content -Path "${winlogbeatBaseConf}winlogbeat.yml" -Raw) -replace 'hosts:.*','hosts: ["192.168.75.129:9092"]') | Set-Content -Path "${winlogbeatBaseConf}winlogbeat.yml"

Write-Host "Install winlogbeat"

PowerShell.exe -ExecutionPolicy UnRestricted -File "${winlogbeatBaseConf}install-service-winlogbeat.ps1"

Write-Host "Installed winlogbeat"

Set-Service winlogbeat -StartupType Automatic

Write-Host "Enable winlogbeat"

Start-Service winlogbeat

Write-Host "Start winlogbeat"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Winlogbeat installation complete!"