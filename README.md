
# Archive File Script - Time Stamper

This script is designed to handle the archiving of a single file that is constantly overwritten without any changes to its name. It monitors the file for changes and creates a timestamped copy of it in a specified target directory. This allows you to maintain an archive of different versions of the file, each identified by its modification time.

## Problem It Solves

The issue this script addresses is the lack of historical versions when a single file is repeatedly updated and overwritten without changing its filename. Without such a solution, you lose previous versions of the file and only retain the most recent one. This script ensures that each version of the file is preserved with a unique timestamped name, enabling you to maintain a complete history of the file's updates.

## Requirements

- **System**: Any system with Python 3.x installed (Linux, Windows, macOS).
- **Python Tools**: Standard Python libraries (`os`, `shutil`, `argparse`, etc.).
- **Permissions**: Write access to the target directory for storing timestamped copies and logs.

## Usage

### Script Parameters

The Python script takes two required arguments:
- `-f`: The path to the file that is constantly overwritten (e.g., `/path/to/source/file.txt`).
- `-t`: The path to the target directory where the archived files will be saved with a timestamp (e.g., `/path/to/timestamped/dropfiles`).

### Example

```bash
python TimeStamper.py -f /path/to/source/file.txt -t /path/to/timestamped/dropfiles
```

### How It Works

1. **Directory Validation**: The script first validates that the target directory exists. If it doesn't, it exits with an error message.
2. **Log File Creation**: It checks if an `archive.log` file exists in the target directory. If not, it creates one to record actions.
3. **File Check**: It scans the target directory for previously archived files and finds the most recent one based on its timestamp.
4. **File Comparison**: The script checks the modification time of the source file and compares it with the most recent archived file. If the file has not been updated, the script logs and outputs "No new file - No Action Required."
5. **Archiving**: If the file has been updated, the script copies it to the target directory, renaming it with the following format: `YYYY-MM-DD_HH.MM.SS_FILENAME`. It logs the action and displays a message confirming the successful archive.
6. **Exit**: The script exits cleanly after completing the task or if it encounters an error (e.g., if the source file cannot be found).

### Crontab Setup (For Linux/MacOS)

To automate this process every 5 minutes, add the following line to your crontab:

```bash
*/5 * * * * /usr/bin/python3 /path/to/TimeStamper.py -f /path/to/source/file.txt -t /path/to/timestamped/dropfiles
```

This will run the script every 5 minutes, checking for changes in the file and archiving it if an update is detected.

### Task Scheduler Setup (For Windows)

To automate this process on Windows using Task Scheduler:

1. Open Task Scheduler and create a new task.
2. Set the trigger to run every 5 minutes.
3. In the "Actions" tab, set the action to "Start a Program" and browse to `python.exe`.
4. Add the following in the "Add arguments" field:
   ```
   TimeStamper.py -f "C:\path\to\source\file.txt" -t "C:\path\to\target\directory"
   ```
5. Save the task, and the script will run automatically at the specified interval.

## Log File

The script generates a log file (`archive.log`) in the target directory that records:
- The time of each action.
- Messages related to file checks, copying, and errors.

### Sample Log Entry

```
2024-10-24 15:30:45 - Most recent archived file has timestamp: 2024-10-24_15.25.30
2024-10-24 15:30:45 - New version of file found. Archiving file to: /path/to/timestamped/dropfiles/2024-10-24_15.30.45_file.txt
```

## Error Handling

- If the target directory is missing, the script outputs:  
  `Could not find the target directory: /path/to/timestamped/dropfiles`
- If the source file cannot be found, the script logs and displays:  
  `Could not find the file at: /path/to/source/file.txt`
- If no files are found in the target directory, it logs:  
  `No files found in target directory. Moving forward to archive...`

## Compatibility

This Python script is compatible with Linux, macOS, and Windows systems. Make sure to have Python 3.x installed and accessible from the terminal or command prompt.

## Contributing

Feel free to open issues or submit pull requests for improvements or bug fixes.

## License

This project is licensed under the MIT License.
