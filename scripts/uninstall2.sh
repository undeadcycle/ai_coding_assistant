# Initialize variables as empty
ROOT_PATH=""
ENV_NAME=""
KERNEL_NAME=""
REPO_DIR=""

# Source the .env file if it exists
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    log "ENV_FILE found and sourced"
else
    log "Note: .env file not found at $ENV_FILE. Proceeding with default values."
fi

# Log the values (or lack thereof) of the variables
log "ROOT_PATH: ${ROOT_PATH:-Not set}"
log "ENV_NAME: ${ENV_NAME:-Not set}"
log "KERNEL_NAME: ${KERNEL_NAME:-Not set}"
log "REPO_DIR: ${REPO_DIR:-Not set}"

# Function to check if a variable is set
is_set() {
    [ -n "${!1}" ]
}

# In the execution section, check each variable before using it

# remove setup.log

# Remove the conda environment
if is_set ENV_NAME; then
    read -p "Remove environment ${ENV_NAME}? (y/n) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_conda_env "$ENV_NAME"
    else
        log "Environment removal cancelled."
    fi
else
    log "Skipping conda environment removal: ENV_NAME not set"
fi

# Remove the Jupyter kernel
if is_set KERNEL_NAME; then
    read -p "Remove Jupyter kernel ${KERNEL_NAME}? (y/n) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_jupyter_kernel "$KERNEL_NAME"
    else
        log "Kernel removal cancelled."
    fi
else
    log "Skipping Jupyter kernel removal: KERNEL_NAME not set"
fi

# Remove the cloned repository
if is_set REPO_DIR; then
    read -p "Remove cloned repository at ${REPO_DIR}? (y/n) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_directory "$REPO_DIR"
    else
        log "Repository removal cancelled."
    fi
else
    log "Skipping repository removal: REPO_DIR not set"
fi

# Remove the .env file
if is_set ROOT_PATH; then
    read -p "Remove .env file? (y/n) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_file "${ROOT_PATH}/.env"
    else
        log ".env file removal cancelled."
    fi
else
    log "Skipping .env file removal: ROOT_PATH not set"
fi

# Remove the __pycache__ directories
if is_set ROOT_PATH; then
    read -p "Remove __pycache__ directories? (y/n) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "${ROOT_PATH}" -name '__pycache__' -type d -exec rm -rf {} +
        log "__pycache__ directories removed."
    else
        log "__pycache__ directories removal cancelled."
    fi
else
    log "Skipping __pycache__ removal: ROOT_PATH not set"
fi