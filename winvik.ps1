Write-Host "##################### SYSTEM INFO #####################"
Get-ComputerInfo -Property CsName,OsName,OsVersion,OsArchitecture,WindowsProductName

Write-Host "##################### USERS&GROUPS INFO #####################"
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
	sc.exe qc $($_.Name) }

#unquoted path
Write-Host -ForegroundColor green "=====> Unquoted Path"
Get-Service | Where-Object { $_.Status -eq "Running" } | ForEach-Object {
    $serviceName = $_.Name
    $output = sc.exe qc $serviceName 2>&1

    $binPathLine = $output | Where-Object { $_ -match 'BINARY_PATH_NAME' }

    if ($binPathLine -match 'BINARY_PATH_NAME\s*:\s*(.+)') {
        $binPath = $matches[1].Trim()

        # Unquoted VE .exe'den önce boşluk var mı?
        if ($binPath -notmatch '^"' -and $binPath -match '^[A-Za-z]:\\.*\s.*\.exe') {
            Write-Host "`n[!] Unquoted Path: $serviceName" -ForegroundColor Red
            Write-Host "    $binPath" -ForegroundColor Yellow
	    sc.exe qc $serviceName	
        }
    }
}

Write-Host "##################### INSTALLED APPs #####################"
#applications
Get-ChildItem 'C:\Program Files', 'C:\Program Files (x86)' | ft Parent,Name,LastWriteTime

Write-Host "##################### Credentials Hunting #####################"
#powershell history
Write-Host -ForegroundColor green "=====> PowerShell History"
Get-ChildItem "C:\Users" -Directory | ForEach-Object { $path = "$($_.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"; if (Test-Path $path) { Write-Host "--- History for User: $($_.Name) $path" -ForegroundColor Cyan } }

#clipboard
Write-Host -ForegroundColor green "=====> Clipboard"
Get-Clipboard
