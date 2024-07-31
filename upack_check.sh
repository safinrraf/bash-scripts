#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.4"
LOG_TIME_FORMAT="%F %T"

CURRENT_DATE=$(date +%Y%m%d)
ARCHIVE_FILE_TIMESTAMP=$(date +%Y%m%d%H%M%S)

BASE_DIR=~/programm/data
DEST_DIR=$BASE_DIR/DEST
ARCHIVE_DIR=$BASE_DIR/ARCHIVE/$CURRENT_DATE
LOG_FILE=$ARCHIVE_DIR/CSV_LOG_$ARCHIVE_FILE_TIMESTAMP.log
CSV_FILE_NAME="FILE.csv"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check for the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_zip_archive (*.zip)> <ZIP password> <SHA256>"
    exit 1
fi

# Check if directory  exists
if [ ! -d "$ARCHIVE_DIR" ]; then
    mkdir $ARCHIVE_DIR
fi

# Define the functions
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

function handle_error {
    eeloggging "$(date +"$LOG_TIME_FORMAT") Caught an error with exit status $?"
}

function clear_tmp {
    loggging "Start clearing"
    rm -f $TEMP_DIR/*.csv
    loggging "Removed CSV file from $TEMP_DIR"
    rm -f $TEMP_DIR/*.zip
    loggging "Removed ZIP file from $TEMP_DIR"
    rm -f $TEMP_DIR/*.txt
    loggging "Removed TXT file from $TEMP_DIR"
    loggging "End clearing"
}

function show_dir_content {
    local PARAMETER_DIR=$1
    loggging "The content of $PARAMETER_DIR"
    ls -halt $PARAMETER_DIR >> $LOG_FILE
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
loggging "BASE_DIR.......$BASE_DIR"
loggging "DEST_DIR.......$DEST_DIR"
loggging "ARCHIVE_DIR....$ARCHIVE_DIR"
loggging "TEMP_DIR.......$TEMP_DIR"
loggging "CURRENT_DATE...$CURRENT_DATE"
loggging "|"
loggging "|"

cp $INPUT_FILE $TEMP_DIR/
echo $INPUT_ZIP_PASSWORD >> $INPUT_ZIP_PASSWORD_FILE
echo $INPUT_SHA256_UPPER >> $INPUT_SHA256_UPPER_FILE
loggging "Created supplimentary files"
unzip -P $INPUT_ZIP_PASSWORD $TEMP_DIR/*.zip -d $TEMP_DIR/
loggging "Unzipped into $TEMP_DIR"
mv $TEMP_DIR/*.csv $TEMP_DIR/$CSV_FILE_NAME
show_dir_content $TEMP_DIR

SHA256_HASH=$(openssl dgst -sha256 $TEMP_DIR/$CSV_FILE_NAME | cut -d' ' -f2 | tr '[:lower:]' '[:upper:]')

loggging "|"
loggging "|"
loggging "INPUT SHA256_HASH $INPUT_SHA256_UPPER"
loggging "CALC  SHA256_HASH $SHA256_HASH"
loggging "|"
loggging "|"

loggging "|"
loggging "Checking the HASH"
loggging "|"
# Compare the strings
if [ "$SHA256_HASH" == "$INPUT_SHA256_UPPER" ]; then
    ggloggging "SHA256_HASH OK"
    loggging "|"
    loggging "|"
else
    eeloggging "SHA256_HASH IS NOT CORRECT"
    clear_tmp
    eeloggging "EXIT"
    exit 1
fi

loggging "|"
loggging "|"
# Checking the format
loggging "Checking the format of the input CSV"
loggging "|"
loggging "|"

first_line=true
line_number=0

while IFS= read -r line
do
    ((line_number++))

    if $first_line; then
        first_line=false
        continue
    fi

    short_line="${line:0:13}"

    # Check if the line matches the pattern: exactly 9 digits
    if [[ $short_line =~ ^[0-9]{10,13}$ ]]; then
        ggloggging "Line $line_number: Valid: $short_line"
    else
        eeloggging "Line $line_number: Invalid: $short_line"
        clear_tmp
        eeloggging "EXIT"
        exit 1
    fi
done < "$TEMP_DIR/$CSV_FILE_NAME"

loggging "|"
loggging "|"

#Archiving previous files
#find $DEST_DIR -type f -name "*.csv" | tar -czvf $ARCHIVE_DIR/CSV_PREV_$ARCHIVE_FILE_TIMESTAMP.tar.gz --remove-files -T -
loggging "Archived previous CSV file"

mv $TEMP_DIR/$CSV_FILE_NAME $DEST_DIR/$CSV_FILE_NAME
loggging "Moved a new CSV to $DEST_DIR"

#Archiving input files
#find $TEMP_DIR -type f -name "*" | tar -czvf $ARCHIVE_DIR/INPUT_$ARCHIVE_FILE_TIMESTAMP.tar.gz --remove-files -T -
loggging "Archived input files files"

show_dir_content $DEST_DIR

clear_tmp

show_dir_content $TEMP_DIR

loggging "End $VERSION: $INPUT_SHA256_UPPER"