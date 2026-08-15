#!/bin/bash
# Start tightvncserver on display :1
vncserver :1 -geometry 1280x720 -depth 24 -localhost no

# Start websockify to bridge VNC to web (noVNC)
websockify --web /usr/share/novnc 6080 localhost:5901