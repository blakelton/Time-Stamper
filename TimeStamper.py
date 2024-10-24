import os
import shutil
import argparse
from datetime import datetime

# Function to display usage and parse command-line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description="Copy a file to a target directory with a timestamp if it's newer.")
    parser.add_argument('-f', '--file', required=True, help="Path to the source file that gets overwritten")
    parser.add_argument('-t', '--target', required=True, help="Directory to copy the file with a timestamp")
    return parser.parse_args()

# Function to log messages to both console and log file
def log_and_display(message, log_file):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_message = f"{timestamp} - {message}"
    print(log_message)
    with open(log_file, 'a') as f:
        f.write(log_message + '\n')

# Main function to handle the file copying with timestamps
def main():
    args = parse_arguments()

    file_path = args.file
    target_dir = args.target

    # Check if the target directory exists
    if not os.path.isdir(target_dir):
        print(f"Could not find the target directory: {target_dir}")
        exit(1)

    # Set up the log file
    log_file = os.path.join(target_dir, 'archive.log')
    if not os.path.isfile(log_file):
        open(log_file, 'w').close()

    # Check if the target directory has archived files and find the most recent timestamp
    latest_timestamp = None
    for file_name in os.listdir(target_dir):
        if file_name.startswith('20') and len(file_name.split('_')[0]) == 10:  # Assumes files start with YYYY-MM-DD format
            timestamp = file_name.split('_')[0] + '_' + file_name.split('_')[1][:8]
            try:
                timestamp_dt = datetime.strptime(timestamp, '%Y-%m-%d_%H.%M.%S')
                if latest_timestamp is None or timestamp_dt > latest_timestamp:
                    latest_timestamp = timestamp_dt
            except ValueError:
                continue

    if latest_timestamp:
        log_and_display(f"Most recent archived file has timestamp: {latest_timestamp.strftime('%Y-%m-%d_%H.%M.%S')}", log_file)
    else:
        log_and_display("No files found in target directory. Moving forward to archive...", log_file)

    # Validate that the source file exists
    if not os.path.isfile(file_path):
        log_and_display(f"Could not find the file at: {file_path}", log_file)
        exit(1)

    # Get the modification time of the source file
    file_mod_time = datetime.fromtimestamp(os.path.getmtime(file_path)).strftime('%Y-%m-%d_%H.%M.%S')

    # Compare timestamps and copy if newer
    if latest_timestamp and file_mod_time == latest_timestamp.strftime('%Y-%m-%d_%H.%M.%S'):
        log_and_display("No new file - No Action Required.", log_file)
    else:
        new_file_name = f"{file_mod_time}_{os.path.basename(file_path)}"
        destination = os.path.join(target_dir, new_file_name)
        try:
            shutil.copy(file_path, destination)
            log_and_display(f"New version of file found. Archiving file to: {destination}", log_file)
        except Exception as e:
            log_and_display(f"Error occurred while copying the file: {str(e)}", log_file)
            exit(1)

if __name__ == '__main__':
    main()
