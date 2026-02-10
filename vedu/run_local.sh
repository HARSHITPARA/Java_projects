#!/bin/bash

# Detect OS
OS="$(uname)"
echo "Detected OS: $OS"

# Detect Local IPv4
# Try hostname -I (Linux) first, then ifconfig (Mac/BSD)
if command -v hostname &> /dev/null && hostname -I &> /dev/null; then
    IP=$(hostname -I | awk '{print $1}')
else
    # Mac/BSD fallback
    IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
fi

if [ -z "$IP" ]; then
    echo "Error: Could not detect Local IP."
    exit 1
fi

echo "Detected Local IP: $IP"

# Define Paths
ENV_FILE=".env"
ROOM_FILE="src/main/resources/static/room.html"

# --- Update .env ---
if [ -f "$ENV_FILE" ]; then
    # Use perl for cross-platform regex replacement (avoids sed -i differences between Mac/Linux)
    perl -i -pe "s/^LAN_PRIVATE_IP=.*/LAN_PRIVATE_IP=$IP/" "$ENV_FILE"
    echo "Updated .env with LAN_PRIVATE_IP=$IP"
else
    echo "Error: .env file not found!"
    exit 1
fi

# --- Update room.html ---
if [ -f "$ROOM_FILE" ]; then
    # Convert IP dots to dashes for the wildcard domain
    DASH_IP="${IP//./-}"
    
    # Update wss URL using perl
    # Matches wss://(any digits or dashes).openvidu-local.dev:7443
    perl -i -pe "s|wss://[\d-]+\.openvidu-local\.dev:7443|wss://$DASH_IP.openvidu-local.dev:7443|" "$ROOM_FILE"
    
    echo "Updated room.html with wss://$DASH_IP.openvidu-local.dev:7443"
else
    echo "Warning: room.html not found!"
fi

# --- Restart Docker ---
echo "Restarting Docker Containers..."
docker-compose down
docker-compose up -d

echo "Success! Application is running."
echo "Access URL: http://$IP:8080"
