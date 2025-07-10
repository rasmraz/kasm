#!/bin/bash
# Custom VNC startup script that allows non-SSL connections

# Copy the original vnc_startup.sh and modify it to remove sslOnly
cp /dockerstartup/vnc_startup.sh /dockerstartup/vnc_startup.sh.backup

# Replace -sslOnly with empty string to allow non-SSL connections
sed -i 's/-sslOnly//g' /dockerstartup/vnc_startup.sh

# Also create a custom kasmvnc.yaml that disables SSL
mkdir -p /home/kasm-default-profile/.vnc
cat > /home/kasm-default-profile/.vnc/kasmvnc.yaml << 'EOF'
logging:
  log_writer_name: all
  log_dest: logfile
  level: 100
network:
  ssl_only: false
  ssl_require_ssl: false
EOF

echo "Modified VNC startup to allow non-SSL connections"