#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.3"
LOG_TIME_FORMAT="%F %T"

BASE_DIR=~/programm/data
CURRENT_DATE=$(date +%Y%m%d)
ARCHIVE_FILE_TIMESTAMP=$(date +%Y%m%d%H%M%S)
DEST_DIR=$BASE_DIR/DEST
ARCHIVE_DIR=$BASE_DIR/ARCHIVE/$CURRENT_DATE
CSV_FILE_NAME="FILE.csv"
LOG_FILE=$BASE_DIR/ARCHIVE/CSV_LOG_$ARCHIVE_FILE_TIMESTAMP.log

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check for the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_zip_archive (*.zip)> <ZIP password> <SHA256>"
    exit 1
fi

# Define the function
function handle_error {
    echo "$(date +"$LOG_TIME_FORMAT") Caught an error with exit status $?" >&2
    echo "$(date +"$LOG_TIME_FORMAT") Caught an error with exit status $?" >> $LOG_FILE
}

function loggging() {
    local message=$1
    echo "$(date +"$LOG_TIME_FORMAT") $message"
    echo "$(date +"$LOG_TIME_FORMAT") $message" >> $LOG_FILE
}

function eeloggging() {
    local message=$1
    echo -e "$(date +"$LOG_TIME_FORMAT") ${RED}$message${NC}"
    echo -e "$(date +"$LOG_TIME_FORMAT") ${RED}$message${NC}" >> $LOG_FILE
}

function ggloggging() {
    local message=$1
    echo -e "$(date +"$LOG_TIME_FORMAT") ${GREEN}$message${NC}"
    echo -e "$(date +"$LOG_TIME_FORMAT") ${GREEN}$message${NC}" >> $LOG_FILE
}

# Set the error handler
trap 'handle_error; exit 1' ERR

# Specify the input file
INPUT_FILE="$1"
INPUT_ZIP_PASSWORD="$2"
INPUT_SHA256="$3"
INPUT_SHA256_UPPER=$(echo $INPUT_SHA256 | tr '[:lower:]' '[:upper:]')
TEMP_DIR=$(mktemp -d)
INPUT_ZIP_PASSWORD_FILE=$TEMP_DIR/inputzippass.txt
INPUT_SHA256_UPPER_FILE=$TEMP_DIR/sha56.txt

### Start the script

loggging "Start $VERSION: $INPUT_SHA256_UPPER"
loggging "BASE_DIR $BASE_DIR"
loggging "TEMP_DIR $TEMP_DIR"
loggging "DEST_DIR $DEST_DIR"
loggging "CURRENT_DATE $CURRENT_DATE"

# Check if directory exists
if [ -d "$ARCHIVE_DIR" ]; then
    loggging "ARCHIVE_DIR $ARCHIVE_DIR"
else
    mkdir $ARCHIVE_DIR
fi

cp $INPUT_FILE $TEMP_DIR/
echo $INPUT_ZIP_PASSWORD >> $INPUT_ZIP_PASSWORD_FILE
echo $INPUT_SHA256_UPPER >> $INPUT_SHA256_UPPER_FILE

unzip -P $INPUT_ZIP_PASSWORD $TEMP_DIR/*.zip -d $TEMP_DIR/
#Archiving previous files
#find $DEST_DIR -type f -name "*.csv" | tar -czvf $ARCHIVE_DIR/CSV_PREV_$ARCHIVE_FILE_TIMESTAMP.tar.gz --remove-files -T -

mv $TEMP_DIR/*.csv $DEST_DIR/$CSV_FILE_NAME

SHA256_HASH=$(openssl dgst -sha256 $DEST_DIR/$CSV_FILE_NAME | cut -d' ' -f2 | tr '[:lower:]' '[:upper:]')

loggging "|"
loggging "|"
loggging "INPUT SHA256_HASH $INPUT_SHA256_UPPER"
loggging "CALC  SHA256_HASH $SHA256_HASH"
loggging "|"
loggging "|"

#Archiving previous files
#find $TEMP_DIR -type f -name "*" | tar -czvf $ARCHIVE_DIR/INPUT_$ARCHIVE_FILE_TIMESTAMP.tar.gz --remove-files -T -
rm -f $TEMP_DIR/*.zip

# Compare the strings
if [ "$SHA256_HASH" == "$INPUT_SHA256_UPPER" ]; then
    ggloggging "SHA256_HASH OK"
    loggging "|"
else
    eeloggging "SHA256_HASH IS NOT CORRECT"
    exit 1
fi

loggging "End $VERSION: $INPUT_SHA256_UPPER"