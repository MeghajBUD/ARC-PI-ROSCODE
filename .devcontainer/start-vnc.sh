#!/bin/bash
vncserver :1 -geometry 1280x720 -depth 24 -localhost no
websockify --web /usr/share/novnc 6080 localhost:5901 &