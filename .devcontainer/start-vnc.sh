#!/bin/bash
set -e

# Kill existing session
vncserver -kill :0 2>/dev/null || true

# Create xstartup for XFCE
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# Set password
echo "vscode" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start VNC server
vncserver :0 -geometry 1280x720 -depth 24 -localhost no

# Start websockify (background, ignore failures)
websockify --web /usr/share/novnc 6080 localhost:5900 --verbose &