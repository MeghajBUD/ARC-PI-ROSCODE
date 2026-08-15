#!/bin/bash
# Exit on error
set -e

# Kill any existing VNC session on display :0
vncserver -kill :0 2>/dev/null || true

# Set VNC password for the current user (vscode)
mkdir -p ~/.vnc
echo "vscode" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start VNC server on display :0
vncserver :0 -geometry 1280x720 -depth 24 -localhost no

# Start websockify to bridge VNC to web (port 6080)
# Use --verbose to log errors if needed
websockify --web /usr/share/novnc 6080 localhost:5900 --verbose &