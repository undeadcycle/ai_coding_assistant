#!/bin/bash

# Get the absolute path minus the current directory
ROOT_PATH=$(dirname "${0%/*}")

# Name of the conda environment
ENV_NAME="codeLlama7bInstruct"
KERNEL_NAME="Python ($ENV_NAME)"

# Set log file and .env file
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

echo "starting log" >> $LOG_FILE

exec > >(tee -a "$LOG_FILE")

# Trap error and write to log file
trap 'echo "$(date) - Error occurred in ${BASH_SOURCE[0]} at line ${LINENO}: $? - $BASH_COMMAND" >> "$LOG_FILE"' ERR

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

# Create and activate conda environment
conda create --name $ENV_NAME python=3.8 -y || {
  echo "Failed to create conda environment" >> $LOG_FILE
  }

# If current conda env does not match ENV_NAME; activate ENV_NAME
if [ "$(conda info --envs | grep '*' | grep -o "$ENV_NAME")" == "" ]; then
  # When conda activate errors out requesting conda init to be run, the eval expression here makes it work without conda init.
  eval "$(conda shell.bash hook)"
  conda activate $ENV_NAME || {
  echo "Conda environment failed to activate" >> $LOG_FILE;
  exit 1;
  }
fi

# Install PyTorch and related libraries
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y || {
  echo "Pytorch/Cuda installation failed" >> $LOG_FILE;
  exit 1;
  }

# Install additional Python packages
for package in ${pip_packages[@]}; do
  pip install $package
done

# Install Jupyter and create a kernel
conda install -c conda-forge jupyter ipykernel -y
python -m ipykernel install --user --name "$ENV_NAME" --display-name "$KERNEL_NAME"



# Make folder for repo
if [ ! -d "$REPO_DIR" ]; then
  mkdir $REPO_DIR
fi



# Check if Git command exists
command -v git &> /dev/null || {
  echo "Git does not exist. Attempting to install" >> $LOG_FILE;
  output=$(conda install git 2>&1);
  echo "Git installation failed: $output" >> $LOG_FILE;
  }

# Clone the GitHub repository (if not already cloned)
if [ ! -d "$REPO_DIR/setup.py" ]; then
  git clone https://github.com/meta-llama/codellama.git $REPO_DIR
  echo "Codellama repository cloned successfully!"
fi

# Install the repository in editable mode
pip install -e $REPO_DIR

# Check if .gitignore exists in the parent directory
if [ ! -f $ROOT_PATH/.gitignore ]; then
  touch $ROOT_PATH/.gitignore
fi

# Ensure that the auth.env and path.env files are ignored
if ! grep -qxF ".env" $ROOT_PATH/.gitignore; then
  echo "*.env" >> $ROOT_PATH/.gitignore
fi

# Final log message
echo "Script completed successfully!" >> $LOG_FILE

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

echo "Checking for required project files:"
for file in "${FILES_TO_CHECK[@]:0:8}"; do
  if [ -e "$file" ]; then
    echo "Found: $file"
  else
    echo "Error: $file not found!"
  fi
done

echo "Checking for model files in ${MODEL_PATH}:"
for ext in "chk" "pth" "json" "model"; do
  echo "Checking for ${ext} files..."
  files=("${MODEL_PATH}"/*."${ext}")
  if [ -e "${files[0]}" ]; then
    echo "Found ${ext} file(s):"
    for file in "${files[@]}"; do
      echo "  $file"
    done
  else
    echo "Warning: No ${ext} files found in ${MODEL_PATH}"
  fi
  echo "Finished checking ${ext} files."
done

echo "File checking completed."

echo "Script completed. Please view the log at $LOG_FILE"