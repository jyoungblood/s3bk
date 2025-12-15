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


# Parse command line arguments
SILENT=0
for arg in "$@"; do
    case $arg in
        -s|--silent)
            SILENT=1
            shift
            ;;
    esac
done

# Logging function (only outputs if not in silent mode)
log() {
    if [ $SILENT -eq 0 ]; then
        echo "$@"
    fi
}

# Exit on error
set -e

# Process each backup path
for BACKUP_CONFIG in "${BACKUP_PATHS[@]}"; do
    LOCAL_PATH="${BACKUP_CONFIG%% => *}"
    S3_DESTINATION="s3://${S3_BUCKET_NAME}/${BACKUP_CONFIG#* => }"

    # Display current backup being processed
    log "Backing up: $LOCAL_PATH"
    log "  Destination: $S3_DESTINATION"

    # Sync files to S3
    log "  Syncing files to S3..."
    if [ $SILENT -eq 1 ]; then
        s3cmd sync "$LOCAL_PATH" "$S3_DESTINATION" >/dev/null
    else
        s3cmd sync "$LOCAL_PATH" "$S3_DESTINATION"
    fi

    log "  Backup completed: $LOCAL_PATH"
    log ""

done

# Display completion message
log "Successfully backed up all static files"
