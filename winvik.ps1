Write-Host "##################### SYSTEM INFO #####################"
Get-ComputerInfo -Property CsName,OsName,OsVersion,OsArchitecture,WindowsProductName

Write-Host "##################### USER INFO #####################"
#whoami
Write-Host -ForegroundColor green "=====> WhoAmI"
whoami /all

#users
Write-Host -ForegroundColor green "=====> All Users"
Get-LocalUser | Select-Object Name,Description,SID,PasswordLastSet,LastLogon

#groups
Write-Host -ForegroundColor green "=====> All Groups"
Get-LocalGroup | Select-Object *

#groupsmember
Write-Host -ForegroundColor green "=====> Members Of Groups"
Get-LocalGroup -PipelineVariable group | Get-LocalGroupMember | Select-Object @{Name="GroupName"; Expression={$group.Name}}, Name, PrincipalSource, ObjectClass

#servcies
Write-Host "##################### SERVICES #####################"
Get-Service | Where-Object {$_.Status -eq "Running"} | ForEach-Object {
	Write-Host "Service Name: $($_.Name)" -ForegroundColor Cyan
	sc.exe qc $_.Name }

Write-Host "##################### Credentials Hunting #####################"
#powershell history
Write-Host -ForegroundColor green "=====> PowerShell History"
Get-ChildItem "C:\Users" -Directory | ForEach-Object { $path = "$($_.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"; if (Test-Path $path) { Write-Host "--- History for User: $($_.Name) $path" -ForegroundColor Cyan } }
