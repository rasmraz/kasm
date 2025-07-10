#!/bin/bash
export DISPLAY=:1
sleep 5  # Wait for X server to start
google-chrome-stable \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --remote-debugging-port=9222 \
    --disable-extensions \
    --disable-plugins \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --window-size=1024,768