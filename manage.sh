#!/bin/bash

# Chrome Webtop Management Script

CONTAINER_NAME="chrome-webtop"
IMAGE_NAME="chrome-webtop"
PORT="12000"

case "$1" in
    start)
        echo "Starting Chrome Webtop..."
        docker run -d \
            --name $CONTAINER_NAME \
            -p $PORT:6901 \
            -e VNC_PW=password \
            --shm-size=512mb \
            $IMAGE_NAME
        echo "Chrome Webtop started on port $PORT"
        echo "Access at: https://work-1-hefnmwebvwfojncq.prod-runtime.all-hands.dev"
        ;;
    stop)
        echo "Stopping Chrome Webtop..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        echo "Chrome Webtop stopped and removed"
        ;;
    restart)
        echo "Restarting Chrome Webtop..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        docker run -d \
            --name $CONTAINER_NAME \
            -p $PORT:6901 \
            -e VNC_PW=password \
            --shm-size=512mb \
            $IMAGE_NAME
        echo "Chrome Webtop restarted"
        ;;
    logs)
        echo "Showing Chrome Webtop logs..."
        docker logs -f $CONTAINER_NAME
        ;;
    status)
        echo "Chrome Webtop status:"
        docker ps | grep $CONTAINER_NAME || echo "Container not running"
        ;;
    build)
        echo "Building Chrome Webtop image..."
        docker build -t $IMAGE_NAME .
        echo "Build complete"
        ;;
    shell)
        echo "Opening shell in Chrome Webtop container..."
        docker exec -it $CONTAINER_NAME /bin/bash
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|build|shell}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the Chrome Webtop container"
        echo "  stop    - Stop and remove the Chrome Webtop container"
        echo "  restart - Restart the Chrome Webtop container"
        echo "  logs    - Show container logs"
        echo "  status  - Show container status"
        echo "  build   - Build the Chrome Webtop image"
        echo "  shell   - Open a shell in the running container"
        exit 1
        ;;
esac