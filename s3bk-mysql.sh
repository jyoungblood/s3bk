#!/bin/bash

# MySQL database backup utility for S3-compatible storage
# https://github.com/jyoungblood/s3bk


# Configuration variables
MYSQL_USER="root"
MYSQL_PASSWORD="xxxxxx"
S3_BUCKET_NAME="xxxxxx"
TEMP_DIR="/tmp"


########################################################################


# Exit on error
set -e

# Timestamp (sortable AND readable)
TIMESTAMP=$(date +"%s - %A %d %B %Y @ %H%M")

# List all databases (excluding system databases)
DATABASES=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)")

# Display backup destination
echo "Backing up databases to: s3://${S3_BUCKET_NAME}/$TIMESTAMP/"

# Process each database
for DATABASE in $DATABASES; do

    # Define backup filenames
    BACKUP_FILENAME="$TIMESTAMP - $DATABASE.sql.gz"
    TEMP_FILE="$TEMP_DIR/$BACKUP_FILENAME"
    S3_OBJECT="s3://${S3_BUCKET_NAME}/$TIMESTAMP/$BACKUP_FILENAME"

    # Display current database being processed
    echo "Processing database: $DATABASE"

    # Create compressed database dump
    echo "  Creating backup file: $TEMP_FILE"
    mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --force --opt --databases "$DATABASE" | gzip -c > "$TEMP_FILE"

    # Upload backup to S3
    echo "  Uploading backup to S3..."
    s3cmd put "$TEMP_FILE" "$S3_OBJECT"

    # Remove temporary backup file
    rm -f "$TEMP_FILE"
    echo "  Backup completed for database: $DATABASE"

done

# Display completion message
echo "Successfully backed up all databases to: s3://${S3_BUCKET_NAME}/$TIMESTAMP/"
