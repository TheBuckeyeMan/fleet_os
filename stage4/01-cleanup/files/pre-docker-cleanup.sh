#!/bin/bash

IMAGE_NAME="thebuckeyeman20/pi:register"
CONTAINER_ID=$(docker ps -a -q --filter ancestor="$IMAGE_NAME")

log() {
  logger -t docker-cleanup "$1"
}

log "[ OK ] Starting the docker cleanup process..."

# Check if the image exists
if docker images "#IMAGE_NAME" | grep -q "$IMAGE_NAME"; then
    log "[ OK ] Image $IMAGE_NAME exists. Benging cleanup sequence."
    #Remove the container
    if [ -n $CONTAINER_ID ]; then
        log "[ INFO ] Stopping containers from image $IMAGE_NAME."
        docker stop $CONTAINER_ID
        docker rm $CONTAINER_ID
        log "[ OK ] Stopped and removed containers form the image $IMAGE_NAME."
    else    
        log "[ INFO ] No containers found from image $IMAGE_NAME."
    fi

    #Remove the image
    log "[ INFO ] Removing the image $IMAGE_NAME."
    docker rmi -f $IMAGE_NAME
    log "[ OK ] Image $IMAGE_NAME has been removed Successfully!"
else
    log "[ INFO ] Image $IMAGE_NAME does not exist. Skipping cleanup."
fi

log "[ OK ] DOcker cleanup process completed successfully!"