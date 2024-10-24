# Function to display usage information
function Show-Usage {
    Write-Host "Usage: TimeStamper.ps1 -FilePath <file-path> -TargetDir <target-directory>"
    Write-Host "  -FilePath: Path to the source file that gets overwritten"
    Write-Host "  -TargetDir: Directory to copy the file with a timestamp"
    exit 1
}

# Parse command-line arguments
param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [Parameter(Mandatory=$true)]
    [string]$TargetDir
)

# Validate that the target directory exists
if (-not (Test-Path -Path $TargetDir -PathType Container)) {
    Write-Host "Could not find the target directory: $TargetDir"
    exit 1
}

# Set up the log file
$logFile = Join-Path $TargetDir "archive.log"
if (-not (Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile
}

# Log and display message function
function Log-And-Display {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Read existing files and find the most recent timestamp
$latestTimestamp = ""
$archivedFiles = Get-ChildItem -Path $TargetDir | Where-Object { $_.Name -match "^\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}_.*" }

if ($archivedFiles.Count -gt 0) {
    foreach ($file in $archivedFiles) {
        $fileName = $file.Name
        $timestamp = $fileName -replace '_.*', ''

        if ($timestamp -match "^\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}$") {
            if (-not $latestTimestamp -or ($timestamp -gt $latestTimestamp)) {
                $latestTimestamp = $timestamp
            }
        }
    }

    if (-not $latestTimestamp) {
        Log-And-Display "No archived files found. Moving forward to archive..."
    } else {
        Log-And-Display "Most recent archived file has timestamp: $latestTimestamp"
    }
} else {
    Log-And-Display "No files found in target directory. Moving forward to archive..."
}

# Validate that the source file exists
if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Log-And-Display "Could not find the file at: $FilePath"
    exit 1
}

# Get the modification time of the source file
$fileModTime = Get-Date (Get-Item -Path $FilePath).LastWriteTime -Format "yyyy-MM-dd_HH.mm.ss"

# Compare timestamps and copy if newer
if ($fileModTime -eq $latestTimestamp) {
    Log-And-Display "No new file - No Action Required."
} else {
    $newFileName = "$fileModTime" + "_" + (Get-Item -Path $FilePath).Name
    Copy-Item -Path $FilePath -Destination (Join-Path $TargetDir $newFileName)
    if ($?) {
        Log-And-Display "New version of file found. Archiving file to: $TargetDir\$newFileName"
        exit 0
    } else {
        Log-And-Display "Error occurred while copying the file."
        exit 1
    }
}
