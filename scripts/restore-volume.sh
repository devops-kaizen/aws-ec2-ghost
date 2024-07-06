#!/bin/bash
# Restore the volume
tar -xzvf /mnt/backup/docker-volume-backup.tar.gz -C /mnt
echo "Volume restored successfully."
