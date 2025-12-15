#!/bin/bash

# Static files backup utility for S3-compatible storage
# https://github.com/jyoungblood/s3bk


# Configuration variables
S3_BUCKET_NAME="xxxxxx"

# Backup paths configuration
# Format: local_path => s3_destination_path
BACKUP_PATHS=(
    "/home/blahblah/xxxxxx/ => xxxxxx/"
    "/home/blahblah/xxxxxx2/ => xxxxxx2/"
)


########################################################################


# Exit on error
set -e

# Process each backup path
for BACKUP_CONFIG in "${BACKUP_PATHS[@]}"; do
    LOCAL_PATH="${BACKUP_CONFIG%% => *}"
    S3_DESTINATION="s3://${S3_BUCKET_NAME}/${BACKUP_CONFIG#* => }"

    # Display current backup being processed
    echo "Backing up: $LOCAL_PATH"
    echo "  Destination: $S3_DESTINATION"

    # Sync files to S3
    echo "  Syncing files to S3..."
    s3cmd sync "$LOCAL_PATH" "$S3_DESTINATION"

    echo "  Backup completed: $LOCAL_PATH"
    echo ""

done

# Display completion message
echo "Successfully backed up all static files"
