#!/bin/bash
# Check if the volume is mounted
if mount | grep /mnt/volume > /dev/null; then
  # Backup the volume
  tar -czvf /mnt/backup/docker-volume-backup.tar.gz -C /mnt/ volume
  echo "Backup created successfully."
else
  echo "Volume is not mounted."
  exit 1
fi
