#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.0"
LOG_TIME_FORMAT="%F %T"

echo "$(date +"$LOG_TIME_FORMAT") Start $VERSION"

find /folder/with/files -name "*.csv" -type -mtime +1 -time -60 | tar -czvf /archive/folder/archive_$(date +%Y%m%d%H%M).tar.gz --remove-files -T -

echo "$(date +"$LOG_TIME_FORMAT") End $VERSION"