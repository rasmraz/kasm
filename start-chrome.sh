#!/bin/bash
export DISPLAY=:1
export HOME=/home/chrome
export USER=chrome

# Create necessary directories
mkdir -p /home/chrome/.local/share/applications
mkdir -p /home/chrome/.config/google-chrome
mkdir -p /home/chrome/.cache

sleep 5  # Wait for X server to be ready
google-chrome-stable \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --window-size=1024,768 \
    --start-maximized \
    --user-data-dir=/home/chrome/.config/google-chrome \
    --crash-dumps-dir=/home/chrome/.cache
