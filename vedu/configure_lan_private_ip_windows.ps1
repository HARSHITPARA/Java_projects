# Get the local IPv4 address (excluding Docker/WSL adapters if possible, picking the first likely candidate)
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "vEthernet|Docker|Loopback" } | Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "Could not detect Local IP. Please check your network." -ForegroundColor Red
    exit 1
}

Write-Host "Detected Local IP: $ip" -ForegroundColor Cameron

# Define the .env file path
$envFile = ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    exit 1
}

# Read the file content
$content = Get-Content $envFile

# Replace the LAN_PRIVATE_IP line
$newContent = $content -replace "^LAN_PRIVATE_IP=.*", "LAN_PRIVATE_IP=$ip"

# Write back to .env
$newContent | Set-Content $envFile

Write-Host "Updated .env with LAN_PRIVATE_IP=$ip" -ForegroundColor Green

# Update room.html
$roomFile = "src\main\resources\static\room.html"
if (Test-Path $roomFile) {
    $roomContent = Get-Content $roomFile
    # Format IP for OpenVidu wildcard (dots to dashes)
    $dashIp = $ip.Replace(".", "-")
    # Regex to replace wss://...openvidu-local.dev
    $newRoomContent = $roomContent -replace "wss://[\d-]+\.openvidu-local\.dev:7443", "wss://$dashIp.openvidu-local.dev:7443"
    $newRoomContent | Set-Content $roomFile
    Write-Host "Updated room.html with wss://$dashIp.openvidu-local.dev:7443" -ForegroundColor Green
} else {
    Write-Host "Warning: room.html not found at $roomFile" -ForegroundColor Yellow
}

# Restart Docker Compose
Write-Host "Restarting Docker Containers..." -ForegroundColor Yellow
docker-compose down
docker-compose up -d

Write-Host "Success! Application is running." -ForegroundColor Green
Write-Host "Access URL: http://$($ip):8080" -ForegroundColor Cyan
