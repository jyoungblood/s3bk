# s3bk

Bash scripts for automating MySQL and static file backups to S3-compatible storage using [s3cmd](https://s3tools.org/s3cmd).

Works with all S3-compatible storage services, including Cloudflare R2.

---

## Prerequisites - s3cmd setup

### Install s3cmd

See the [s3cmd documentation](https://s3tools.org/repositories) to find the appropriate repository for your distro.

### Configure s3cmd

Run the configuration wizard to set up your S3 credentials:

```bash
s3cmd --configure
```

Configure your credentials for AWS S3, Cloudflare R2, or other S3-compatible storage service. The configuration file is saved to `$HOME/.s3cfg` by default.

### Requirements

- The user running the scripts must have permission to execute `mysqldump` (for MySQL backups)
- Ensure the scripts are executable and owned by the user who will run it

---

## s3bk-mysql setup

This script dumps all databases (excluding system databases), compresses them, and uploads them to S3.

1. Download the script to your machine:

```bash
cd ~
curl -O https://raw.githubusercontent.com/jyoungblood/s3bk/0.1.0/s3bk-mysql.sh
```

2. Edit the configuration variables at the top of the script:
```bash
nano ~/s3bk-mysql.sh
```
```bash
MYSQL_USER="root"
MYSQL_PASSWORD="rootP4$5w0Rd"
S3_BUCKET_NAME="bucket"
S3_DESTINATION_PATH="destination/path"
```

3. Make the script executable:

```bash
chmod +x ~/s3bk-mysql.sh
```

The script is now ready to use. Feel free to test it:
```bash
./s3bk-mysql.sh
```

The script can also be run in silent mode (suppressing normal output, only showing errors):
```bash
./s3bk-mysql.sh --silent
```

4. Set up a cron job (optional):

```bash
crontab -e
```

Add a line to run the backup daily (at 3 AM, for example):

```
0 3 * * * bash ~/s3bk-mysql.sh --silent
```

### Notes:
- Root access is typically required if backing up all databases. 
- You may also need to modify the database exclusion filter if you want to exclude additional databases beyond the default system databases.
- If using Plesk, you may want to set the password using: `MYSQL_PASSWORD="$(cat /etc/psa/.psa.shadow)"`
- This script uses mysqldump command's `-p` flag, so don't be alarmed when you see the standard *"mysqldump: [Warning] Using a password on the command line interface can be insecure."*

---

## s3bk-static setup

This script syncs local directories of static files to a specific S3 location.

1. Download the script to your machine:

```bash
cd ~
curl -O https://raw.githubusercontent.com/jyoungblood/s3bk/0.1.0/s3bk-static.sh
```

2. Edit the configuration variables at the top of the script:

```bash
nano ~/s3bk-static.sh
```

```bash
S3_BUCKET_NAME="bucket"

# Backup paths configuration
# Format: local_path => s3_destination_path
BACKUP_PATHS=(
    "/home/blahblah/media/ => /static/media/"
    "/home/blahblah/videos/ => /static/videos/"
)
```

3. Make the script executable:

```bash
chmod +x ~/s3bk-static.sh
```

The script is now ready to use. Feel free to test it:
```bash
./s3bk-static.sh
```

The script can also be run in silent mode (suppressing normal output, only showing errors):
```bash
./s3bk-static.sh --silent
```

4. Set up a cron job (optional):

```bash
crontab -e
```

Add a line to run the backup daily (at 3 AM, for example):
```
0 3 * * * bash ~/s3bk-static.sh --silent
```
