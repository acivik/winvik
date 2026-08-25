Write-Host "##################### SYSTEM INFO #####################"
Get-ComputerInfo -Property CsName,OsName,OsVersion,OsArchitecture,WindowsProductName

Write-Host -ForegroundColor green "=====> Patches"
Get-HotFix | Sort-Object -Descending -Property InstalledOn -ErrorAction SilentlyContinue | Select-Object HotfixID, Description, InstalledBy, InstalledOn | Format-Table -AutoSize | Out-String | Write-Host

Write-Host "##################### USERS & GROUPS INFO #####################"
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
Write-Host -ForegroundColor green "=====> Member Of Group"
Get-LocalGroup | ForEach-Object {
    $groupName = $_.Name
    Write-Host "`nGroup Name: $groupName"
    net localgroup "$groupName" 2>$null |
        Where-Object { $_ -match '\S' -and $_ -notmatch '^(Alias|Comment|Members|--|The command)' }
}

#servcies
Write-Host "##################### SERVICES #####################"
Get-Service | Where-Object {$_.Status -eq "Running"} | ForEach-Object {
	Write-Host "Service Name: $($_.Name)" }

#unquoted path
Write-Host -ForegroundColor green "=====> Unquoted Path"
Get-Service | Where-Object { $_.Status -eq "Running" } | ForEach-Object {
    $serviceName = $_.Name
    $output = sc.exe qc $serviceName 2>&1

    $binPathLine = $output | Where-Object { $_ -match 'BINARY_PATH_NAME' }

    if ($binPathLine -match 'BINARY_PATH_NAME\s*:\s*(.+)') {
        $binPath = $matches[1].Trim()

        # Unquoted and spaces check
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

Write-Host "##################### PROCESSES #####################"
Get-CimInstance Win32_Process | Select-Object Name, ProcessId, ParentProcessId, CommandLine | Out-String | Write-Host

Write-Host "##################### Network #####################"
#ipinfo
Write-Host -ForegroundColor green "=====> IP Info"
ipconfig.exe /all
Write-Host -ForegroundColor green "=====> Interfaces"
Get-NetIPAddress | Select-Object -Property InterfaceAlias, IPAddress | Out-String | Write-Host
#network activity
Write-Host -ForegroundColor green "=====> Network Activity"
$Procs = Get-Process | Group-Object -Property Id -AsHashTable -AsString
Get-NetTCPConnection -State Listen, Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess,@{Name='Process'; Expression={ $Procs[[string]$_.OwningProcess].ProcessName }} | Format-Table -AutoSize

Write-Host "##################### Credentials Hunting #####################"
Write-Host -ForegroundColor green "=====> PowerShell History"
Get-ChildItem "C:\Users" -Directory | ForEach-Object {
    $path = "$($_.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $path) { Write-Host "--- History for User: $($_.Name) $path" -ForegroundColor Cyan }
}

Write-Host -ForegroundColor green "=====> Clipboard"
Get-Clipboard | Out-String | Write-Host
