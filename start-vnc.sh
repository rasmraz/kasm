#!/bin/bash
export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x24 &
sleep 2
fluxbox &
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -rfbport 5901 -shared -forever &
cd /opt/noVNC && ./utils/novnc_proxy --vnc localhost:5901 --listen 6901