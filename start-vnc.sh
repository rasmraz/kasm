#!/bin/bash
export DISPLAY=:1
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -rfbport 5901 -forever
