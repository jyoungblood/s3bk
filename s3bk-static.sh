#!/bin/bash

# Static files backup utility for S3-compatible storage
# https://github.com/jyoungblood/s3bk


# Configuration variables
S3_BUCKET_NAME="xxxxxx"

# Backup paths configuration
# Format: local_path => s3_destination_path
BACKUP_PATHS=(
    "/home/xxxxxx/xxxxxx/ => /static/xxxxxx/"
    "/home/xxxxxx/xxxxxx2/ => /static/xxxxxx2/"
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

# Normalize S3 destination path: remove leading/trailing slashes, then add trailing slash if not empty
# This allows users to specify paths with or without slashes (e.g., "backups/static", "/backups/static/", etc.)
normalize_s3_path() {
    local path="$1"
    if [ -n "$path" ]; then
        path=$(echo "$path" | sed 's|^/||;s|/$||')
        path="${path}/"
    fi
    echo "$path"
}

# Process each backup path
for BACKUP_CONFIG in "${BACKUP_PATHS[@]}"; do
    LOCAL_PATH="${BACKUP_CONFIG%% => *}"
    S3_DESTINATION_PATH="${BACKUP_CONFIG#* => }"
    S3_DESTINATION_PATH=$(normalize_s3_path "$S3_DESTINATION_PATH")
    S3_DESTINATION="s3://${S3_BUCKET_NAME}/${S3_DESTINATION_PATH}"

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
