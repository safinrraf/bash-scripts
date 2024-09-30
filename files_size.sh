#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.0"
LOG_TIME_FORMAT="%F %T"

# This script is just about saving a cool commands
# The task: I have files in the folder, and I want to group them by date and get the sum of the file's size grouped by date
# and sorted by date

ls -l --time-style=+%Y-%m-%d | awk '{print $6, $5/1024/1024/1024}' | tail -n +2 | sort | awk '{arr[$1]+=$2} END {for (i in arr) print i, arr[i] " GB"}' | sort

# Example of the output
# 2024-07-08 7.45058e-09 GB
# 2024-09-19 2.14863 GB
# 2024-09-21 0.507958 GB
# 2024-09-24 1.38158 GB
# 2024-09-25 8.07622 GB
# 2024-09-26 1.75404 GB
# 2024-09-27 1.82597 GB
# 2024-09-30 3.09214 GB