#!/bin/bash

# Function to display usage information
function usage() {
    echo "Usage: $0 -f <file-path> -t <target-directory>"
    echo "  -f: Path to the source file that gets overwritten"
    echo "  -t: Directory to copy the file with a timestamp"
    exit 1
}

# Check if arguments are provided
if [ "$#" -lt 4 ]; then
    usage
fi

# Parse command-line arguments
while getopts ":f:t:" opt; do
    case $opt in
        f) file_path="$OPTARG"
           ;;
        t) target_dir="$OPTARG"
           ;;
        *) usage
           ;;
    esac
done

# Ensure both arguments are provided
if [ -z "$file_path" ] || [ -z "$target_dir" ]; then
    usage
fi

# Validate that the target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Could not find the target directory: $target_dir"
    exit 1
fi

# Set up the log file
log_file="$target_dir/archive.log"
if [ ! -f "$log_file" ]; then
    touch "$log_file"
fi

# Log and display message function
function log_and_display() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" | tee -a "$log_file"
}

# Read existing files and find the most recent timestamp
latest_timestamp=""
if compgen -G "$target_dir/*" > /dev/null; then
    for file in "$target_dir"/????-??-??_??.??.??_*; do
        filename=$(basename "$file")
        timestamp=$(echo "$filename" | cut -d'_' -f 1,2)
        
        if [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\.[0-9]{2}\.[0-9]{2}$ ]]; then
            if [[ -z "$latest_timestamp" || "$timestamp" > "$latest_timestamp" ]]; then
                latest_timestamp="$timestamp"
            fi
        fi
    done
    
    if [ -z "$latest_timestamp" ]; then
        log_and_display "No archived files found. Moving forward to archive..."
    else
        log_and_display "Most recent archived file has timestamp: $latest_timestamp"
    fi
else
    log_and_display "No files found in target directory. Moving forward to archive..."
fi

# Validate that the file exists
if [ ! -f "$file_path" ]; then
    log_and_display "Could not find the file at: $file_path"
    exit 1
fi

# Get the modification time of the source file
file_mod_time=$(date -r "$file_path" +"%Y-%m-%d_%H.%M.%S")

# Compare timestamps and copy if newer
if [ "$file_mod_time" == "$latest_timestamp" ]; then
    log_and_display "No new file - No Action Required."
else
    new_filename="${file_mod_time}_$(basename "$file_path")"
    cp "$file_path" "$target_dir/$new_filename"
    if [ $? -eq 0 ]; then
        log_and_display "New version of file found. Archiving file to: $target_dir/$new_filename"
        exit 0
    else
        log_and_display "Error occurred while copying the file."
        exit 1
    fi
fi

exit 0