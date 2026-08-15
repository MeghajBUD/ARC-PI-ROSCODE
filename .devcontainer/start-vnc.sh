#!/bin/bash
# Start VNC server on display :1
vncserver :1 -geometry 1280x720 -depth 24 -localhost no

# Start websockify in the background so the script can exit
websockify --web /usr/share/novnc 6080 localhost:5901 &