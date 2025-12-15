#!/bin/bash

# MySQL database backup utility for S3-compatible storage
# https://github.com/jyoungblood/s3bk


# Configuration variables
MYSQL_USER="root"
MYSQL_PASSWORD="xxxxxx"
S3_BUCKET_NAME="xxxxxx"
S3_DESTINATION_PATH="xxxxxx"
TEMP_DIR="/tmp"


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

# Normalize S3_DESTINATION_PATH: remove leading/trailing slashes, then add trailing slash if not empty
# This allows users to specify paths with or without slashes (e.g., "backups/mysql", "/backups/mysql/", etc.)
if [ -n "$S3_DESTINATION_PATH" ]; then
    S3_DESTINATION_PATH=$(echo "$S3_DESTINATION_PATH" | sed 's|^/||;s|/$||')
    S3_DESTINATION_PATH="${S3_DESTINATION_PATH}/"
fi

# Timestamp (sortable AND readable)
TIMESTAMP=$(date +"%s - %A %d %B %Y @ %H%M")

# List all databases (excluding system databases)
DATABASES=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)")

# Display backup destination
log "Backing up databases to: s3://${S3_BUCKET_NAME}/${S3_DESTINATION_PATH}$TIMESTAMP/"

# Process each database
for DATABASE in $DATABASES; do

    # Define backup filenames
    BACKUP_FILENAME="$TIMESTAMP - $DATABASE.sql.gz"
    TEMP_FILE="$TEMP_DIR/$BACKUP_FILENAME"
    S3_OBJECT="s3://${S3_BUCKET_NAME}/${S3_DESTINATION_PATH}$TIMESTAMP/$BACKUP_FILENAME"

    # Display current database being processed
    log "Processing database: $DATABASE"

    # Create compressed database dump
    log "  Creating backup file: $TEMP_FILE"
    mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --force --opt --databases "$DATABASE" | gzip -c > "$TEMP_FILE"

    # Upload backup to S3
    log "  Uploading backup to S3..."
    if [ $SILENT -eq 1 ]; then
        s3cmd put "$TEMP_FILE" "$S3_OBJECT" >/dev/null
    else
        s3cmd put "$TEMP_FILE" "$S3_OBJECT"
    fi

    # Remove temporary backup file
    rm -f "$TEMP_FILE"
    log "  Backup completed for database: $DATABASE"

done

# Display completion message
log "Successfully backed up all databases to: s3://${S3_BUCKET_NAME}/${S3_DESTINATION_PATH}$TIMESTAMP/"
