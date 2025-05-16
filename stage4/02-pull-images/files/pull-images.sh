#1/bin/bash

IMAGE_NAME="thebuckeyeman20/pi:register"

log() {
    logger -t pull-image-pull "$1"
}

log "[ INFO ] STarting the docker pull images process..."

#Check if docker is installed, if not, exit
if ! command -v docker &> /dev/null; then
    log "[ ERROR ] Docker is not installed. Docker will not attempt to pull image as it is not installed."
    exit 0
fi

# Check if the image exists already, if so, exit
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGE_NAME$"; then
  log "[ ERROR ] Image $IMAGE_NAME already exists but should have been removed in 01-cleanup. Please check the cleanup process. Docker will not attempt to pull image as it already exists."
  exit 0
else
    # Pull the image
    log "[ INFO ] Pulling the docker image $IMAGE_NAME..."
    docker pull "$IMAGE_NAME" 2>&1 | logger -t docker-image-pull
    log "[ OK ] Docker image $IMAGE_NAME has been pulled successfully!"
fi