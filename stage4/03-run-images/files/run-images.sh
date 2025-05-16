#! /bin/bash

IMAGE_NAME="thebuckeyeman20/pi:register"
CONTAINER_NAME="pi-register"

log() {
  logger -t docker-run-stage "$1"
}

log "[ INFO ] Starting the docker run stage for container $CONTAINER_NAME"

# Check if container is already running
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  log "[ ERROR ] Container $CONTAINER_NAME is already running and should not be. Exiting.."
  exit 0
fi

#Run the container
log "[ INFO ] Launching container $CONTAINER_NAME..."
docker run -d --name "$CONTAINER_NAME" --restart unless-stopped "$IMAGE_NAME" 2>&1 | logger -t docker-run
log "[ OK ] Container $CONTAINER_NAME has been launched successfully!"


