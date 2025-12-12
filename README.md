# s3bk

bash scripts for automating mysql and static file backups to s3 using [s3cmd](https://s3tools.org/s3cmd)

works with all s3-compatible storage (including r2)

---


# s3cmd setup

### Install s3cmd

see the docs and find the right repository for your distro - https://s3tools.org/repositories



### Configure with s3 credentials

```
s3cmd --configure
```

add your creds for aws s3 or cloudflare r2 (or any s3-compatible storage)

defaults to $HOME/.s3cfg, make sure you put the creds in the right place



the following instructions will be
assuming your config is in the same dir as the script (and you're cd'd to that dir) (which we'll assume is '/~'), and that your user that runs the script can run mysqldump
  also assuming you're doing this as the user who will run the script, otherwise you'll need to chown as well once it's been created & updated


---






## s3bk-mysql (mysql backup script)


[] curl download

nano s3bk-mysql.sh
  (add your mysql creds)
  - also need to exclude any databases that don’t need to be backed up (ex: |reininghost_rsdb\)


make it executable
```
chmod +x ~/s3bk-mysql.sh
```

[] set cron job
```
crontab -e
```
0 3 * * * bash ~/s3mysqlbackup.sh
(i set it to run at 3am)
```





TIPS
- one time i had to set password to `mysqlpassword="$(cat /etc/psa/.psa.shadow)"`​ but it worked lol








## s3bk-static



[] curl download



nano s3bk-static.sh
  add your file path that you want to back up (the whole directory) and 


make it executable
```
chmod +x ~/s3bk-mysql.sh
```

[] set cron job
```
crontab -e
```
0 3 * * * bash ~/s3mysqlbackup.sh
(i set it to run at 3am)
```








---

based on David King's s3mysqlbackup.sh - https://gist.github.com/oodavid/2206527/
shout out to a real legend