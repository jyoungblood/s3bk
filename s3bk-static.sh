#!/bin/bash

# Backup static files outside of git repositories

s3cmd sync /home/blahblah/media.blahblah.com/ s3://blahblah-static-bk/media.blahblah.com/

