#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory (project root)
ROOT_PATH="$( cd "$SCRIPT_DIR/.." && pwd )"

# Name of the conda environment an jupyter kernel
ENV_NAME="codellama7binstruct"
KERNEL_NAME="$ENV_NAME"

# Set sutup.log, .env, and git_repo as variables
LOG_FILE="$ROOT_PATH/setup.log"
ENV_FILE="$ROOT_PATH/.env"
REPO_DIR="$ROOT_PATH/git_repo"

# PIP packages
pip_packages=(
  "diffusers"
  "transformers"
  "accelerate"
  "python-dotenv"
  )

log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "starting script... \n"

# Debugging: Uncomment the following line if you want to log all terminal output (bash -x is preferred)
# exec > >(tee -a "$LOG_FILE")

# Trap error and write to log file
trap 'log "\n$(date) - Error occurred in ${BASH_SOURCE[0]} at line ${LINENO}: $? - $BASH_COMMAND\n" >> "$LOG_FILE"' ERR

# Debugging: Test the error trap by using a failing command
log "Testing the error trap..."
false

# Variables to write to .env file
env_vars=(
  "ROOT_PATH=$ROOT_PATH"
  "ENV_NAME=$ENV_NAME"
  "KERNEL_NAME=\"$KERNEL_NAME\""
  "REPO_DIR=$REPO_DIR"
)

# Prompt user for MODEL_PATH if not set in .env file
if [ ! -f "$ENV_FILE" ] || ! grep -q "MODEL_PATH=" "$ENV_FILE"; then
  read -p "Enter the location (absolute path) of the model files: " MODEL_PATH
  env_vars+=("MODEL_PATH=$MODEL_PATH")
else
  MODEL_PATH=$(grep "MODEL_PATH=" "$ENV_FILE" | cut -d '=' -f2)
fi

# Write variables to .env file
for var in "${env_vars[@]}"; do
  if ! grep -q "${var%%=*}=" "$ENV_FILE"; then
    echo "$var" >> "$ENV_FILE"
  fi
done

log "\n"

# Create and activate conda environment
if conda info --envs | grep -q "$ENV_NAME"; then
  log "Conda environment $ENV_NAME already exists"
else
  log "Creating conda environment $ENV_NAME"
  conda create --name $ENV_NAME python=3.8 -y && log "Conda environment created successfully" || log "Failed to create conda environment "
fi

# If current conda env does not match ENV_NAME; activate ENV_NAME
if [ "$(conda info --envs | grep '*' | grep -o "$ENV_NAME")" == "" ]; then
  # When conda activate errors out requesting conda init to be run, the eval expression here makes it work without conda init.
  eval "$(conda shell.bash hook)"
  conda activate $ENV_NAME && log "Conda environment $ENV_NAME activated successfully" || {
  log "Conda environment failed to activate";
  exit 1;
}
fi

# Install PyTorch and related libraries
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y && log "PyTorch/Cuda installed successfully \n" || {
  log "Pytorch/Cuda installation failed \n";
  exit 1;
  }

# Install additional Python packages
for package in ${pip_packages[@]}; do
  pip install $package && log "$package installed successfully" || log "Failed to install $package"
done

# Install Jupyter and create a kernel
conda install -c conda-forge jupyter ipykernel -y && log "ipykernel installed successfuly"
python -m ipykernel install --user --name "$ENV_NAME" --display-name "$KERNEL_NAME" && log "Jupyter kernel created successfully \n" || log "Failed to create Jupyter kernel /n"

# Make folder for repo
if [ -d "$REPO_DIR" ]; then
  log "Codellama git directory already exists"
else
  mkdir $REPO_DIR && log "Successfully created $REPO_DIR" || log "Failed to create $REPO_DIR"
fi

# Check if Git command exists
command -v git &> /dev/null || {
  log "Git does not exist. Attempting to install";
  output=$(conda install git 2>&1);
  log "Git installation failed: $output";
  }

# Clone the GitHub repository (if not already cloned)
if [ -f "$REPO_DIR/setup.py" ]; then
  log "Codellama repository already exists"
else
  git clone https://github.com/meta-llama/codellama.git $REPO_DIR && log "CodeLlama repository cloned successfully!" || log "Failed to clone CodeLlama repository"
fi

# Install the repository in editable mode
pip install -e $REPO_DIR && log "CodeLlama repository successfully installed \n" || log "Failed to install CodeLlama repository \n"

# Check if .gitignore exists in the parent directory
if [ -f $ROOT_PATH/.gitignore ]; then
  log ".gitignore file already exists"
else
  touch $ROOT_PATH/.gitignore && log "Created .gitignore file" || log "Failed to create .gitignore file"
fi

# Ensure that the auth.env and path.env files are ignored
if grep -qxF "*.env" $ROOT_PATH/.gitignore; then
  log "*.env already in .gitignore \n"
else
  echo "*.env" >> $ROOT_PATH/.gitignore && log "Added *.env to .gitignore \n" || log "Failed to add *.env to .gitignore \n"
fi

# Check if all files exist in correct location
FILES_TO_CHECK=(
  "${ROOT_PATH}/README.md"
  "${ROOT_PATH}/scripts/conda_env.sh"
  "${ROOT_PATH}/scripts/uninstall.sh"
  "${ROOT_PATH}/src/auth.py"
  "${ROOT_PATH}/src/chatbot.py"
  "${ROOT_PATH}/src/gui.py"
  "${ROOT_PATH}/src/main.py"
  "${ROOT_PATH}/.env"
  "${ROOT_PATH}/.gitignore"

)

log "Checking for required project files:"
for file in "${FILES_TO_CHECK[@]:0:8}"; do
  if [ -e "$file" ]; then
    log "Found: $file"
  else
    log "Error: $file not found!"
  fi
done

log "MODEL_PATH is set to: ${MODEL_PATH}"

if [ ! -d "${MODEL_PATH}" ]; then
  log "ERROR: Directory ${MODEL_PATH} does not exist"
  return 1
fi

if [ ! -r "${MODEL_PATH}" ]; then
  log "ERROR: No read permissions for ${MODEL_PATH}"
  return 1
fi

log "Checking for model files in ${MODEL_PATH}:"

shopt -s nullglob
for ext in "chk" "pth" "json" "model"; do
  log "Checking for ${ext} files..."
  files=("${MODEL_PATH}"/*."${ext}")
  if [ ${#files[@]} -gt 0 ]; then
    log "Found ${#files[@]} ${ext} file(s):"
    for file in "${files[@]}"; do
      log "  $file"
    done
  else
    log "WARNING: No ${ext} files found in ${MODEL_PATH}"
  fi
  log "Finished checking ${ext} files."
done
shopt -u nullglob

log "File checking completed. \n"

log "Script completed. Please view the log at $LOG_FILE"