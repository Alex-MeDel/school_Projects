# ==========================================
# WINDOWS BOOTSTRAP: Internal App Servers
# ==========================================

# 1. Start Logging 
# You can RDP into the server later and read this file to verify the setup
Start-Transcript -Path "C:\bootstrap_log.txt" -Force
Write-Output "Starting Windows Server Bootstrap Process..."

# 2. NTP Configuration (Amazon Time Sync Service)
# Fulfills the "NTP (trusted servers)" requirement natively for Windows
Write-Output "Configuring W32Time to use Amazon Time Sync..."
# Point Windows Time service to the AWS link-local IP
w32tm /config /syncfromflags:manual /manualpeerlist:"169.254.169.123,0x9" /update
Restart-Service w32time
w32tm /resync /rediscover

# 3. OS-Level Domain Lockdown Fallback
# Fulfills "Locks down unauthorized domains" by routing bad domains to localhost
Write-Output "Configuring local DNS lockdown via hosts file..."
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
Add-Content -Path $hostsPath -Value "`n127.0.0.1`tmalware.local"
Add-Content -Path $hostsPath -Value "127.0.0.1`tevil.local"
Add-Content -Path $hostsPath -Value "127.0.0.1`tveryevil.local"

# 4. Install Application Server Roles (IIS)
# Gives the App Server a purpose and proves it's working
Write-Output "Installing Web Server (IIS) Role..."
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Replace default IIS page with a custom server identifier
$serverName = $env:COMPUTERNAME
$html = "<html><body><h1>Welcome to Internal App Server: $serverName</h1><p>Provisioned automatically via Terraform.</p></body></html>"
Set-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value $html

# 5. OS-Level Program Lockdown (Windows Defender)
# Fulfills the paper's mention of restricting unauthorized programs locally
Write-Output "Enabling Strict Windows Defender Policies..."
Set-MpPreference -EnableControlledFolderAccess Enabled
Set-MpPreference -PUAProtection Enabled

Write-Output "Windows Bootstrap Complete!"
Stop-Transcript