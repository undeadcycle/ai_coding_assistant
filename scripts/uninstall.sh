#!/bin/bash

###################
# Configuration
###################

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory (project root)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Check if we're in the correct directory structure
if [[ ! -d "$PROJECT_ROOT/scripts" ]] || [[ ! -d "$PROJECT_ROOT/src" ]]; then
    echo "Error: Script is not in the expected directory structure" >&2
    exit 1
fi

# Define log and env file paths
LOG_FILE="${PROJECT_ROOT}/uninstall.log"
ENV_FILE="${PROJECT_ROOT}/.env"

log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Script directory: $SCRIPT_DIR"
log "Project root: $PROJECT_ROOT"
log "Log file: $LOG_FILE"
log "Env file: $ENV_FILE \n"

# Debugging: Uncomment the following line if you want to log all terminal output (bash -x is preferred)
# exec > >(tee -a "$LOG_FILE")

# Trap error and write to log file
trap 'log "TRAPED ERROR: \nError occurred in ${BASH_SOURCE[0]} at line ${LINENO}: $? - $BASH_COMMAND"' ERR

# Debugging: Test the error trap by using a failing command
log "Testing the error trap..."
false

# Source the .env file if it exists
if [ -e "$ENV_FILE" ]; then
  source "$ENV_FILE"
  log "ENV_FILE found successfully: \n"
else
  log "Error: .env file not found at $ENV_FILE"
  exit 1
fi

log "ROOT_PATH: $ROOT_PATH"
log "ENV_NAME: $ENV_NAME"
log "KERNEL_NAME: $KERNEL_NAME"
log "REPO_DIR: $REPO_DIR \n"

# Debugging: Uncomment this line if you want to test verify 
# exit 1
###################
# Functions
###################

# remove setup.log

# Remove conda environment
remove_conda_env() {
  local env_name="$1"
  if conda env list | grep -q "^$env_name\s"; then
    conda remove --name "$env_name" --all -y
    log "Environment $env_name removed."
  else
    log "WARNING: Environment $env_name not found."
  fi
}

# Remove Jupyter kernel
remove_jupyter_kernel() {
  local kernel_name="$1"
  if jupyter kernelspec list | grep -q "$kernel_name"; then
    jupyter kernelspec remove "$kernel_name" -y
    log "Jupyter kernel $kernel_name removed."
  else
    log "WARNING: Jupyter kernel $kernel_name not found."
  fi
}

# Function to remove directory
remove_directory() {
  local dir_path="$1"
  if [ -d "$dir_path" ]; then
    rm -rf "$dir_path"
    log "Directory $dir_path removed."
  else
    log "WARNING: $dir_path not found."
  fi
}

# Function to remove file
remove_file() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    rm "$file_path"
    log "File $file_path removed."
  else
    log "WARNING: $file_path not found."
  fi
}

# Function to remove pycache
remove_pycache() {
  if [ -d "$PROJECT_ROOT/__pycache__" ]; then
    find "${PROJECT_ROOT}" -name '__pycache__' -type d -exec rm -rf {} +
    log "Directory __pycache__ removed"
  else
    log "Pycache directory not found"
  fi
}

###################
# Execution
###################

# Remove the conda environment
read -p "Remove environment ${ENV_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_conda_env "$ENV_NAME"
else
  log "Environment removal cancelled."
fi

# Remove the Jupyter kernel
read -p "Remove Jupyter kernel ${KERNEL_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_jupyter_kernel "$KERNEL_NAME"
else
  log "Kernel removal cancelled."
fi

# Remove the cloned repository
read -p "Remove cloned repository at ${REPO_DIR}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_directory "$REPO_DIR"
else
  log "Repository removal cancelled."
fi

# Remove the .env file
read -p "Remove .env file? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_file "${ROOT_PATH}/.env"
else
  log ".env file removal cancelled."
fi

# Remove the __pycache__ directories
read -p "Remove __pycache__ directories? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_pycache "${PROJECT_ROOT}"
else
  log "__pycache__ directories removal cancelled."
fi

log "Uninstall script completed. Please view the log at $LOG_FILE"

