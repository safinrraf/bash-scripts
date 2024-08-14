#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 file1.csv file2.csv file3.csv"
    exit 1
fi

# Define the CSV files from input parameters
file1="$1"
file2="$2"
file3="$3"

# Read the headers
header1=$(head -n 1 "$file1")
header2=$(head -n 1 "$file2")
header3=$(head -n 1 "$file3")

# Compare the headers
if [[ "$header1" == "$header2" && "$header2" == "$header3" ]]; then
    echo "All files have the same header."
else
    echo "The files do not have the same header."
fi