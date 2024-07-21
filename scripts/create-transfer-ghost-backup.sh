# create-transfer-ghost-backup.sh file
#!/bin/bash

# Define variables
VOLUME_NAME="some-ghost-data"
CONTAINER_NAME="some-ghost"
BACKUP_DIR="$(pwd)/backup"
BACKUP_FILE="ghost-backup-$(date +%Y%m%d%H%M%S).tar.gz"
REMOTE_USER="vivek"
REMOTE_HOST="server.digitalocean.com"
REMOTE_PATH="/home/vivek/some-ghost-sync"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Stop the Docker container
echo "Stopping Docker container..."
if docker stop $CONTAINER_NAME; then
  echo "Docker container stopped."
else
  echo "Error: Failed to stop Docker container."
  exit 1
fi

# Backup the Docker volume
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

# Start the Docker container
echo "Starting Docker container..."
if docker start $CONTAINER_NAME; then
  echo "Docker container started."
else
  echo "Error: Failed to start Docker container."
  exit 1
fi

# Ask if the user wants to transfer the file to a remote VM
read -p "Do you want to transfer the backup file to the remote VM? (y/n): " transfer

if [ "$transfer" = "y" ]; then
  # Ensure the remote directory exists
  echo "Ensuring remote directory exists..."
  ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_PATH"

  # Transfer the backup file to the remote VM
  echo "Transferring backup file to remote VM..."
  if scp $BACKUP_DIR/$BACKUP_FILE $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH; then
    echo "Backup file transferred to $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
  else
    echo "Error: File transfer failed."
    exit 1
  fi
else
  echo "Backup file not transferred."
fi
