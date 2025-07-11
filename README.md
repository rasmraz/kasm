# Chrome Webtop - One Command Installation

A complete Chrome webtop that can be installed and launched with a single command. This provides a web-accessible Chrome browser running in a containerized desktop environment with VNC access.

## 🚀 One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/rasmraz/kasm/feature/chrome-webtop-vnc-implementation/install.sh | bash
```

**That's it!** The script will:
- ✅ Install Docker (if not present)
- ✅ Build the Chrome webtop image
- ✅ Start the container
- ✅ Configure all services
- ✅ Provide access information

## 🌐 Access Your Chrome Webtop

After installation, open your browser and go to:
**http://localhost:12000**

1. Click **"Connect"** in the noVNC interface
2. Start using Chrome in your web browser!

## ⚡ Quick Commands

```bash
# Download and run the installer
./install.sh

# View container logs
./install.sh --logs

# Check status
./install.sh --status

# Clean up everything
./install.sh --cleanup

# Use custom port
./install.sh --port 8080

# Get help
./install.sh --help
```

## 🎯 What You Get

- **🌐 Web-Accessible Chrome Browser** - Full Chrome functionality through your web browser
- **🖥️ Complete Desktop Environment** - Fluxbox window manager with VNC access
- **🔧 Zero Configuration** - Everything works out of the box
- **🐳 Containerized** - Isolated, secure, and easy to manage
- **📱 Modern Interface** - noVNC provides responsive web-based VNC client
- **🔗 HTTP Compatible** - No SSL issues with proxy environments

## 🛠️ Manual Installation (Alternative)

If you prefer manual control:

```bash
# Clone repository
git clone https://github.com/rasmraz/kasm.git
cd kasm

# Run installer
./install.sh
```

## 📋 System Requirements

- **OS**: Linux (Ubuntu/Debian recommended), macOS with Docker Desktop
- **RAM**: 2GB minimum, 4GB recommended
- **Docker**: Will be installed automatically if not present
- **Ports**: 12000 (default, configurable)

## 🔧 Configuration Options

### Environment Variables
```bash
# Custom port
HOST_PORT=8080 ./install.sh

# Container settings are automatically optimized
```

### Container Management
```bash
# View running container
docker ps | grep chrome-webtop

# Stop container
docker stop chrome-webtop

# Start container
docker start chrome-webtop

# Remove container
docker rm chrome-webtop

# Access container shell
docker exec -it chrome-webtop bash
```

## 🏗️ Architecture

**Simplified Stack:**
- **Base**: Ubuntu 22.04
- **VNC Server**: x11vnc (HTTP-compatible)
- **Web Interface**: noVNC 1.3.0
- **Desktop**: Fluxbox window manager
- **Browser**: Google Chrome stable
- **Process Manager**: Supervisor

**Why This Works:**
- ✅ No SSL-only restrictions (unlike Kasm VNC)
- ✅ HTTP proxy compatible
- ✅ Lightweight and fast
- ✅ Modern web interface
- ✅ Reliable service management

## 🔍 Troubleshooting

### Container Won't Start
```bash
# Check Docker status
docker info

# View detailed logs
./install.sh --logs

# Restart Docker (Linux)
sudo systemctl restart docker
```

### Can't Access Web Interface
```bash
# Check if container is running
./install.sh --status

# Test local connection
curl -I http://localhost:12000

# Check port conflicts
netstat -tulpn | grep 12000
```

### Performance Issues
```bash
# Increase shared memory
docker run --shm-size=1gb ...

# Check system resources
docker stats chrome-webtop
```

## 🔒 Security Features

- Container runs as non-root user
- Chrome sandbox enabled
- VNC access without password (localhost only)
- Isolated container environment
- No persistent data storage by default

## 🚀 Advanced Usage

### Custom Chrome Settings
```bash
# Access container and modify Chrome
docker exec -it chrome-webtop bash
# Edit /usr/local/bin/start-chrome.sh
```

### Persistent Data
```bash
# Mount home directory
docker run -v /host/path:/home/chrome ...
```

### Multiple Instances
```bash
# Run on different ports
HOST_PORT=8080 ./install.sh
HOST_PORT=8081 ./install.sh
```

## 📊 Comparison with Original Kasm

| Feature | Original Kasm | This Implementation |
|---------|---------------|-------------------|
| Installation | Complex multi-step | Single command |
| SSL Requirements | SSL-only VNC | HTTP compatible |
| Size | Large (~2GB) | Optimized (~800MB) |
| Startup Time | Slow | Fast |
| Proxy Compatibility | Issues | Perfect |
| Maintenance | Complex | Simple |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test with `./install.sh`
4. Submit a pull request

## 📄 License

Open source - see individual component licenses.

## 🆘 Support

- **Quick Help**: `./install.sh --help`
- **Logs**: `./install.sh --logs`
- **Status**: `./install.sh --status`
- **Issues**: Open a GitHub issue

---

**🎉 Enjoy your one-command Chrome webtop!**