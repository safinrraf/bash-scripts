#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.0"
LOG_TIME_FORMAT="%F %T"

BASE_DIR=~/data/
IN_DIR=$BASE_DIR/IN/archive
MERGE_TXNS_DIR=$BASE_DIR/IN/log
CURRENT_YEAR=$(date +%Y)
ARCHIVE_DIR=$BASE_DIR/CSV_ARCHIVE/IN/$CURRENT_YEAR
PREV_MONTH=`date -d "$(date +%Y-%m-1) -1 month" +%Y%m`

echo "$(date +"$LOG_TIME_FORMAT") Start $VERSION"
echo "$(date +"$LOG_TIME_FORMAT") Start moving files to the archive" 
echo "$(date +"$LOG_TIME_FORMAT") In folder $IN_DIR"
echo "$(date +"$LOG_TIME_FORMAT") Current year $CURRENT_YEAR"
echo "$(date +"$LOG_TIME_FORMAT") Archive folder $ARCHIVE_DIR"
echo "$(date +"$LOG_TIME_FORMAT") Previous month $PREV_MONTH"
echo "$(date +"$LOG_TIME_FORMAT") Merge Exns folder $MERGE_TXNS_DIR"


echo "$(date +"$LOG_TIME_FORMAT") Start archiving Merge Txns "
#find $MERGE_TXNS_DIR -type f -name "mergetxng*$PREV_MONTH*.log" | tar -czvf $ARCHIVE_DIR/mergetxns_archive_$PREV_MONTH.tar.gz --remove-files -I -

echo "$(date +"$LOG_TIME_FORMAT") Start archiving input trxng"
#find $IN DIR -type f -name "aml*$PREV_MONTH*,csv.save" | tar -czvf $ARCHIVE DIR/input trns archive_$PREV MONTH.tar.gz --remove-files -T -

echo "$(date +"$LOG_TIME_FORMAT") Start archiving archives"

echo "$(date +"$LOG_TIME_FORMAT") End $VERSION"