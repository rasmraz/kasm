#!/bin/bash

# Chrome Webtop One-Command Installer
# This script automates the complete setup of a Chrome webtop with VNC web access

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="chrome-webtop"
IMAGE_NAME="chrome-webtop-simple"
PORT=${PORT:-6901}
HOST_PORT=${HOST_PORT:-12000}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Docker if not present
install_docker() {
    if command_exists docker; then
        print_status "Docker is already installed"
        return 0
    fi
    
    print_status "Installing Docker..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Update package index
        sudo apt-get update
        
        # Install required packages
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        
        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker Engine
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Add current user to docker group
        sudo usermod -aG docker $USER
        
        print_warning "You may need to log out and back in for Docker group membership to take effect"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_error "Please install Docker Desktop for Mac from https://docs.docker.com/desktop/mac/install/"
        exit 1
    else
        print_error "Unsupported operating system. Please install Docker manually."
        exit 1
    fi
}

# Function to start Docker daemon if not running
start_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_status "Starting Docker daemon..."
        if command_exists systemctl; then
            sudo systemctl start docker
            sudo systemctl enable docker
        elif command_exists service; then
            sudo service docker start
        else
            print_error "Cannot start Docker daemon. Please start it manually."
            exit 1
        fi
        
        # Wait for Docker to be ready
        print_status "Waiting for Docker to be ready..."
        for i in {1..30}; do
            if docker info >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done
        
        if ! docker info >/dev/null 2>&1; then
            print_error "Docker failed to start properly"
            exit 1
        fi
    fi
    
    print_success "Docker is running"
}

# Function to stop and remove existing container
cleanup_existing() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Stopping and removing existing container: ${CONTAINER_NAME}"
        docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
        docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
    fi
}

# Function to create Dockerfile
create_dockerfile() {
    print_status "Creating optimized Dockerfile..."
    
    cat > Dockerfile.simple << 'EOF'
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    net-tools \
    gnupg \
    tigervnc-common \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C /opt/noVNC && \
    wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash chrome && \
    echo 'chrome:password' | chpasswd

# Create supervisor log directory
RUN mkdir -p /var/log/supervisor

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
COPY start-chrome.sh /usr/local/bin/start-chrome.sh
RUN chmod +x /usr/local/bin/start-vnc.sh /usr/local/bin/start-chrome.sh

# Set up VNC directory
RUN mkdir -p /home/chrome/.vnc && \
    chown -R chrome:chrome /home/chrome/.vnc

EXPOSE 6901

USER chrome
WORKDIR /home/chrome

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
EOF
}

# Function to create supervisor configuration
create_supervisor_config() {
    print_status "Creating supervisor configuration..."
    
    cat > supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
user=chrome
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1024x768x24
autorestart=true
stdout_logfile=/var/log/supervisor/xvfb.log
stderr_logfile=/var/log/supervisor/xvfb.log

[program:fluxbox]
command=/usr/bin/fluxbox
environment=DISPLAY=":1"
autorestart=true
stdout_logfile=/var/log/supervisor/fluxbox.log
stderr_logfile=/var/log/supervisor/fluxbox.log

[program:x11vnc]
command=/usr/local/bin/start-vnc.sh
autorestart=true
stdout_logfile=/var/log/supervisor/x11vnc.log
stderr_logfile=/var/log/supervisor/x11vnc.log

[program:novnc]
command=/usr/bin/python3 /opt/noVNC/utils/websockify/websockify.py --web /opt/noVNC 6901 localhost:5901
autorestart=true
stdout_logfile=/var/log/supervisor/novnc.log
stderr_logfile=/var/log/supervisor/novnc.log

[program:chrome]
command=/usr/local/bin/start-chrome.sh
environment=DISPLAY=":1"
autorestart=true
stdout_logfile=/var/log/supervisor/chrome.log
stderr_logfile=/var/log/supervisor/chrome.log
EOF
}

# Function to create VNC startup script
create_vnc_script() {
    print_status "Creating VNC startup script..."
    
    cat > start-vnc.sh << 'EOF'
#!/bin/bash
export DISPLAY=:1
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -rfbport 5901 -forever
EOF
    chmod +x start-vnc.sh
}

# Function to create Chrome startup script
create_chrome_script() {
    print_status "Creating Chrome startup script..."
    
    cat > start-chrome.sh << 'EOF'
#!/bin/bash
export DISPLAY=:1
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
    --start-maximized
EOF
    chmod +x start-chrome.sh
}

# Function to build Docker image
build_image() {
    print_status "Building Chrome webtop Docker image..."
    docker build -f Dockerfile.simple -t ${IMAGE_NAME} .
    print_success "Docker image built successfully"
}

# Function to run container
run_container() {
    print_status "Starting Chrome webtop container..."
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${HOST_PORT}:${PORT} \
        --shm-size=512mb \
        --restart=unless-stopped \
        ${IMAGE_NAME}
    
    print_success "Container started successfully"
}

# Function to wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to start..."
    
    for i in {1..30}; do
        if curl -s http://localhost:${HOST_PORT} >/dev/null 2>&1; then
            print_success "Services are ready!"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    print_warning "Services may still be starting. Check logs with: docker logs ${CONTAINER_NAME}"
}

# Function to display access information
show_access_info() {
    echo
    echo "=============================================="
    echo -e "${GREEN}Chrome Webtop Installation Complete!${NC}"
    echo "=============================================="
    echo
    echo -e "${BLUE}Access Information:${NC}"
    echo "  Local URL:  http://localhost:${HOST_PORT}"
    echo "  Container:  ${CONTAINER_NAME}"
    echo "  Image:      ${IMAGE_NAME}"
    echo
    echo -e "${BLUE}Usage:${NC}"
    echo "  1. Open the URL in your web browser"
    echo "  2. Click 'Connect' to establish VNC connection"
    echo "  3. Use Chrome browser in the desktop environment"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "  View logs:     docker logs ${CONTAINER_NAME}"
    echo "  Stop:          docker stop ${CONTAINER_NAME}"
    echo "  Start:         docker start ${CONTAINER_NAME}"
    echo "  Restart:       docker restart ${CONTAINER_NAME}"
    echo "  Remove:        docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
    echo "  Shell access:  docker exec -it ${CONTAINER_NAME} bash"
    echo
    echo -e "${BLUE}Troubleshooting:${NC}"
    echo "  If connection fails, wait a few more seconds for services to fully start"
    echo "  Check container status: docker ps"
    echo "  View detailed logs: docker logs -f ${CONTAINER_NAME}"
    echo
}

# Main installation function
main() {
    echo "=============================================="
    echo -e "${BLUE}Chrome Webtop One-Command Installer${NC}"
    echo "=============================================="
    echo
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root is not recommended. Consider running as a regular user."
    fi
    
    # Install Docker if needed
    install_docker
    
    # Start Docker daemon
    start_docker
    
    # Clean up any existing container
    cleanup_existing
    
    # Create all necessary files
    create_dockerfile
    create_supervisor_config
    create_vnc_script
    create_chrome_script
    
    # Build and run
    build_image
    run_container
    
    # Wait for services and show info
    wait_for_services
    show_access_info
    
    print_success "Installation completed successfully!"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Chrome Webtop One-Command Installer"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --port PORT         Set host port (default: 12000)"
        echo "  --cleanup           Remove existing container and image"
        echo "  --logs              Show container logs"
        echo "  --status            Show container status"
        echo
        echo "Environment Variables:"
        echo "  HOST_PORT           Host port to bind to (default: 12000)"
        echo "  PORT                Container port (default: 6901)"
        echo
        exit 0
        ;;
    --cleanup)
        print_status "Cleaning up existing container and image..."
        docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
        docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
        docker rmi ${IMAGE_NAME} >/dev/null 2>&1 || true
        print_success "Cleanup completed"
        exit 0
        ;;
    --logs)
        if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            docker logs -f ${CONTAINER_NAME}
        else
            print_error "Container ${CONTAINER_NAME} is not running"
            exit 1
        fi
        ;;
    --status)
        if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            print_success "Container ${CONTAINER_NAME} is running"
            docker ps --filter "name=${CONTAINER_NAME}"
            echo
            print_status "Access URL: http://localhost:${HOST_PORT}"
        else
            print_error "Container ${CONTAINER_NAME} is not running"
            exit 1
        fi
        ;;
    --port)
        if [[ -n "${2:-}" ]]; then
            HOST_PORT="$2"
            shift 2
        else
            print_error "Port number required after --port"
            exit 1
        fi
        main "$@"
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac