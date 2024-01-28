#!/bin/bash

PROGRAM=${0##*/} # the version
VERSION="$PROGRAM v1.0.0"
LOG_TIME_FORMAT="%F %T"

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_csv_file> <number of lines per file>"
    exit 1
fi

echo "$(date +"$LOG_TIME_FORMAT") Start $VERSION"

# Create a temporary directory for the split files
temp_dir=$(mktemp -d)

# Specify the input file
input_file="$1"

# Specify the number of lines per split file (including the header)
lines_per_file="$2"

header=$temp_dir/header
tmp_file_with_header=$temp_dir/tmp_file_with_header

csv_filename_without_extension="${input_file%.*}_"

# extract header row and save
head -n1 $input_file > $header

echo "$(date +"$LOG_TIME_FORMAT") Input file=$input_file has $(wc -l $input_file | awk '{print $1}') lines"
echo "$(date +"$LOG_TIME_FORMAT") Lines per file=$lines_per_file"
echo "$(date +"$LOG_TIME_FORMAT") Temp directory=$temp_dir"
echo "$(date +"$LOG_TIME_FORMAT") The CSV file without an extension=$csv_filename_without_extension"

# Step 1: split the input_file file without the header line
tail -n +2 "$input_file" | split -d -l "$lines_per_file" - "$csv_filename_without_extension"

# Step 2: add the header line to each split file
for file in $csv_filename_without_extension*
do
  cat $header "$file" > $tmp_file_with_header
  mv -f $tmp_file_with_header "$file".csv
  rm -f $file
  echo "$(date +"$LOG_TIME_FORMAT") New file=$file.csv has $(wc -l $file.csv | awk '{print $1}') lines"
done

# Remove the temporary directory
rm -f $header
rmdir "$temp_dir"

echo "$(date +"$LOG_TIME_FORMAT") End $VERSION"