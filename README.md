# s3bk

Bash scripts for automating MySQL and static file backups to S3-compatible storage using [s3cmd](https://s3tools.org/s3cmd).

Works with all S3-compatible storage services, including Cloudflare R2.

---

## Prerequisites

### Install s3cmd

See the [s3cmd documentation](https://s3tools.org/repositories) to find the appropriate repository for your distro.

### Configure s3cmd

Run the configuration wizard to set up your S3 credentials:

```bash
s3cmd --configure
```

Configure your credentials for AWS S3, Cloudflare R2, or any other S3-compatible storage service. The configuration file is saved to `$HOME/.s3cfg` by default.

### Requirements

- The user running the script must have permission to execute `mysqldump` (for MySQL backups)
- Ensure the script is executable and owned by the user who will run it

---

## s3bk-mysql

Automated MySQL database backup script that dumps all databases (excluding system databases) to S3.

### Setup

1. Download the script to your machine:

```bash
cd ~
curl -O https://raw.githubusercontent.com/jyoungblood/s3bk/0.1/s3bk-mysql.sh
```

2. Edit the configuration variables at the top of the script:
```bash
nano ~/s3bk-mysql.sh
```
```bash
MYSQL_USER="root"
MYSQL_PASSWORD="xxxxxx"
S3_BUCKET_NAME="xxxxxx
```

**Note:** Root access is typically required if backing up all databases. You may also need to modify the database exclusion filter if you want to exclude additional databases beyond the default system databases.

3. Make the script executable:

```bash
chmod +x ~/s3bk-mysql.sh
```

4. Set up a cron job (optional):

```bash
crontab -e
```

Add a line to run the backup daily (at 3 AM, for example):

```
0 3 * * * bash ~/s3bk-mysql.sh
```

### Tips

- If using Plesk, you may need to set the password using: `MYSQL_PASSWORD="$(cat /etc/psa/.psa.shadow)"`

---

## s3bk-static

Automated static file backup script that syncs local directories to S3.

### Setup

1. Download the script to your machine:

```bash
cd ~
curl -O https://raw.githubusercontent.com/jyoungblood/s3bk/0.1/s3bk-mysql.sh
```



2. Edit the configuration variables at the top of the script:

```bash
nano ~/s3bk-static.sh
```

```bash
S3_BUCKET_NAME="xxxxxx"

# Backup paths configuration
# Format: local_path => s3_destination_path
BACKUP_PATHS=(
    "/path/to/local/directory/ => s3_destination_path/"
    "/another/local/path/ => another_destination/"
)
```

The script will automatically prefix `s3://${S3_BUCKET_NAME}/` to each destination path.

3. Make the script executable:

```bash
chmod +x ~/s3bk-static.sh
```

4. Set up a cron job (optional):

```bash
crontab -e
```

Add a line to run the backup daily (at 3 AM, for example):

```
0 3 * * * bash ~/s3bk-static.sh
```

---

## Credits

Based on David King's [s3mysqlbackup.sh](https://gist.github.com/oodavid/2206527/).
