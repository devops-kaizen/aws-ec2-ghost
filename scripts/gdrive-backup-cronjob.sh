#!/bin/bash

# Define variables
VOLUME_NAME="some-ghost-data"
CONTAINER_NAME="some-ghost"
BACKUP_DIR="$(pwd)/backup"
BACKUP_FILE="ghost-backup-$(date +%Y%m%d%H%M%S).tar.gz"
LAST_BACKUP_FILE="ghost-backup-last.tar.gz"
REMOTE_PATH="gdrive:/backups/ghost-tech-blog"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Function to create backup
create_backup() {
  echo "Stopping Docker container..."
  if docker stop $CONTAINER_NAME; then
    echo "Docker container stopped."
  else
    echo "Error: Failed to stop Docker container."
    exit 1
  fi

  echo "Creating backup of Docker volume..."
  if docker run --rm \
    --mount source=$VOLUME_NAME,target=/data \
    -v $BACKUP_DIR:/backup \
    busybox \
    tar -czvf /backup/$BACKUP_FILE -C /data .; then
    echo "Backup completed: $BACKUP_DIR/$BACKUP_FILE"
  else
    echo "Error: Backup failed."
    exit 1
  fi

  echo "Starting Docker container..."
  if docker start $CONTAINER_NAME; then
    echo "Docker container started."
  else
    echo "Error: Failed to start Docker container."
    exit 1
  fi

  # Update the last backup file
  cp $BACKUP_DIR/$BACKUP_FILE $BACKUP_DIR/$LAST_BACKUP_FILE

  # Upload the new backup to Google Drive
  echo "Uploading backup to Google Drive..."
  if rclone copy $BACKUP_DIR/$BACKUP_FILE $REMOTE_PATH; then
    echo "Backup file uploaded to Google Drive."
  else
    echo "Error: File upload failed."
    exit 1
  fi
}

# Check if there are any changes since the last backup
echo "Checking for changes since the last backup..."
if [ -f "$BACKUP_DIR/$LAST_BACKUP_FILE" ]; then
  CURRENT_CHECKSUM=$(docker run --rm \
    --mount source=$VOLUME_NAME,target=/data \
    busybox \
    tar -C /data -cf - . | md5sum | awk '{ print $1 }')

  LAST_CHECKSUM=$(tar -tf $BACKUP_DIR/$LAST_BACKUP_FILE | md5sum | awk '{ print $1 }')

  if [ "$CURRENT_CHECKSUM" != "$LAST_CHECKSUM" ]; then
    echo "Changes detected, creating a new backup."
    create_backup
  else
    echo "No changes detected, no backup needed."
  fi
else
  echo "No previous backup found, creating a new backup."
  create_backup
fi
