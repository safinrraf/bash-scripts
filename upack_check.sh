#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.0"
LOG_TIME_FORMAT="%F %T"

BASE_DIR=~/programm/data
CURRENT_DATE=$(date +%Y%m%d)
ARCHIVE_FILE_TIMESTAMP=$(date +%Y%m%d%H%M%S)
DEST_DIR=$BASE_DIR/DEST
ARCHIVE_DIR=$BASE_DIR/ARCHIVE/$CURRENT_DATE
CSV_FILE_NAME="FILE.csv"

# Check for the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_zip_archive (*.zip)> <ZIP password> <SHA256>"
    exit 1
fi

# Define the function
function handle_error {
    echo "$(date +"$LOG_TIME_FORMAT") Caught an error with exit status $?" >&2
}

# Set the error handler
trap 'handle_error; exit 1' ERR

# Specify the input file
INPUT_FILE="$1"
INPUT_ZIP_PASSWORD="$2"
INPUT_SHA256="$3"
INPUT_SHA256_UPPER=$(echo $INPUT_SHA256 | tr '[:lower:]' '[:upper:]')
TEMP_DIR=$(mktemp -d)

### Start the script

echo "$(date +"$LOG_TIME_FORMAT") Start $VERSION"
echo "$(date +"$LOG_TIME_FORMAT") BASE_DIR $BASE_DIR"
echo "$(date +"$LOG_TIME_FORMAT") TEMP_DIR $TEMP_DIR"
echo "$(date +"$LOG_TIME_FORMAT") DEST_DIR $DEST_DIR"
echo "$(date +"$LOG_TIME_FORMAT") CURRENT_DATE $CURRENT_DATE"

# Check if directory exists
if [ -d "$ARCHIVE_DIR" ]; then
    echo "$(date +"$LOG_TIME_FORMAT") ARCHIVE_DIR $ARCHIVE_DIR"
else
    mkdir $ARCHIVE_DIR
fi

cp $INPUT_FILE $TEMP_DIR/
unzip -P $INPUT_ZIP_PASSWORD $TEMP_DIR/*.zip -d $TEMP_DIR/
#Archiving previous files
find $DEST_DIR -type f -name "*.csv" | tar -czvf $ARCHIVE_DIR/PEP_$ARCHIVE_FILE_TIMESTAMP.tar.gz --remove-files -T -

mv $TEMP_DIR/*.csv $DEST_DIR/$CSV_FILE_NAME

SHA256_HASH=$(openssl dgst -sha256 $DEST_DIR/$CSV_FILE_NAME | cut -d' ' -f2 | tr '[:lower:]' '[:upper:]')

echo "|"
echo "|"
echo "$(date +"$LOG_TIME_FORMAT") INPUT SHA256_HASH $INPUT_SHA256_UPPER"
echo "$(date +"$LOG_TIME_FORMAT") CALC  SHA256_HASH $SHA256_HASH"
echo "|"
echo "|"

rm -f $TEMP_DIR/*.zip

# Compare the strings
if [ "$SHA256_HASH" == "$INPUT_SHA256_UPPER" ]; then
    echo "$(date +"$LOG_TIME_FORMAT") SHA256_HASH OK"
    echo "|"
else
    echo "$(date +"$LOG_TIME_FORMAT") SHA256_HASH IS NOT CORRECT"
    exit 1
fi

echo "$(date +"$LOG_TIME_FORMAT") End $VERSION"