#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
  copy_previous
fi

# Set permissions globally for ALL stages
find . -name "*.conf" -exec chmod 644 {} \;
find . -name "*.service" -exec chmod 644 {} \;
find . -name "*.py" -exec chmod 755 {} \;
find . -name "*.sh" -exec chmod 755 {} \;