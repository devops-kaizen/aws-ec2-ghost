#!/bin/bash

# Define the directory structure
declare -A DIRS_FILES=(
    ["aws-docker-project/terraform/"]="main.tf variables.tf outputs.tf provider.tf terraform.tfvars"
    ["aws-docker-project/terraform/scripts/"]="setup-docker.sh"
    ["aws-docker-project/ansible/"]="deploy-docker.yml inventory vars.yml"
    ["aws-docker-project/scripts/"]="backup-volume.sh restore-volume.sh"
    ["aws-docker-project/"]="README.md .gitignore"
)

# Create directories and files
for DIR in "${!DIRS_FILES[@]}"; do
    mkdir -p "$DIR"  # Create directory
    for FILE in ${DIRS_FILES[$DIR]}; do
        touch "$DIR/$FILE"  # Create file
    done
done

echo "Directory structure created successfully."

# Make scripts executable
chmod +x aws-docker-project/terraform/scripts/setup-docker.sh
chmod +x aws-docker-project/scripts/backup-volume.sh
chmod +x aws-docker-project/scripts/restore-volume.sh

echo "Scripts made executable."

