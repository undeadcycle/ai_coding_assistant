#!/bin/bash

LOG_FILE="./uninstall.log"
ENV_FILE="../.env"

exec > >(tee -a "$LOG_FILE")

# Trap error and write to log file
trap 'echo "$(date) - Error occurred in ${BASH_SOURCE[0]} at line ${LINENO}: $? - $BASH_COMMAND" >> "$LOG_FILE"' ERR

# Source the .env file if it exists
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "Error: .env file not found at $ENV_FILE"
  exit 1
fi

# Function to remove conda environment
remove_conda_env() {
  local env_name="$1"
  if conda env list | grep -q "^$env_name\s"; then
    conda remove --name "$env_name" --all -y
    echo "Environment $env_name removed."
  else
    echo "Environment $env_name not found."
  fi
}

# Function to remove Jupyter kernel
remove_jupyter_kernel() {
  local kernel_name="$1"
  if jupyter kernelspec list | grep -q "$kernel_name"; then
    jupyter kernelspec remove "$kernel_name" -y
    echo "Jupyter kernel $kernel_name removed."
  else
    echo "Jupyter kernel $kernel_name not found."
  fi
}

# Function to remove directory
remove_directory() {
  local dir_path="$1"
  if [ -d "$dir_path" ]; then
    rm -rf "$dir_path"
    echo "Directory $dir_path removed."
  else
    echo "Directory $dir_path not found."
  fi
}

# Function to remove file
remove_file() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    rm "$file_path"
    echo "File $file_path removed."
  else
    echo "File $file_path not found."
  fi
}

# Remove the conda environment
read -p "Remove environment ${ENV_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_conda_env "$ENV_NAME"
else
  echo "Environment removal cancelled."
fi

# Remove the Jupyter kernel
read -p "Remove Jupyter kernel ${KERNEL_NAME}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_jupyter_kernel "$KERNEL_NAME"
else
  echo "Kernel removal cancelled."
fi

# Remove the cloned repository
read -p "Remove cloned repository at ${REPO_DIR}? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_directory "$REPO_DIR"
else
  echo "Repository removal cancelled."
fi

# Remove the .env file
read -p "Remove .env file? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_file "${ROOT_PATH}/.env"
else
  echo ".env file removal cancelled."
fi

# Remove the models directory
read -p "Remove models directory? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  remove_directory "${ROOT_PATH}/models"
else
  echo "Models directory removal cancelled."
fi

# Remove the __pycache__ directories
read -p "Remove __pycache__ directories? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  find "${ROOT_PATH}" -name '__pycache__' -type d -exec rm -rf {} +
  echo "__pycache__ directories removed."
else
  echo "__pycache__ directories removal cancelled."
fi

echo "Uninstall script completed. Please view the log at $LOG_FILE"
