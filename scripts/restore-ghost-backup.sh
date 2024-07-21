# restore-ghost-backup.sh file
#!/bin/bash

# Define variables
VOLUME_NAME="some-ghost-data"
BACKUP_FILE=$1  # Path to the backup file
CONTAINER_NAME="some-ghost"
TEMP_DIR="/tmp/ghost-restore"

# Check if the backup file is provided
if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <path-to-backup-file>"
  exit 1
fi

# Check if the backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 1
fi

# Stop and remove the existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

# Remove the existing Docker volume if it exists
if docker volume inspect $VOLUME_NAME >/dev/null 2>&1; then
  echo "Removing existing Docker volume: $VOLUME_NAME"
  docker volume rm $VOLUME_NAME
fi

# Create a new Docker volume
echo "Creating new Docker volume: $VOLUME_NAME"
docker volume create $VOLUME_NAME

# Create a temporary directory for extracting the backup
mkdir -p $TEMP_DIR

# Extract the backup file into the temporary directory
echo "Extracting backup file..."
tar -xzvf $BACKUP_FILE -C $TEMP_DIR

# Restore the backup to the Docker volume
echo "Restoring backup to Docker volume..."
docker run --rm \
  --mount source=$VOLUME_NAME,target=/data \
  -v $TEMP_DIR:/backup \
  busybox \
  cp -r /backup/. /data

# Clean up the temporary directory
rm -rf $TEMP_DIR

echo "Restore completed."

# Restart the Ghost container with the restored volume
echo "Starting Ghost container..."
docker run -d \
  --name $CONTAINER_NAME \
  -e NODE_ENV=development \
  -e database__connection__filename='/var/lib/ghost/content/data/ghost.db' \
  -e url=http://blog.vivekteega.com \
  -p 2368:2368 \
  -v $VOLUME_NAME:/var/lib/ghost/content \
  ghost
echo "Ghost container started."
